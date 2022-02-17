defmodule Kojin.Rust.Field do
  @moduledoc """
  Rust _struct_ _field_ definition.
  """

  use TypedStruct
  use Vex.Struct

  alias Kojin.Rust.{Field, Type}
  alias Kojin.Utils
  import Kojin.Rust.Attr
  import Utils

  @valid_accesses [:ro, :ro_ref, :rw, :rw_ref, :ia]

  @typedoc """
  A *field* of a _struct_.

  * :name - The field name in _snake case_
  * :doc - Documentation for the field
  * :type - The rust type of the field
  * :visibility - The visibility for the field (eg :pub, :pub(crate), etc)
  """
  typedstruct enforce: true do
    field(:name, binary)
    field(:doc, String.t(), enforce: false)
    field(:type, Type.t())
    field(:access, atom | nil)
    field(:visibility, atom, default: :pub)
    field(:attrs, list(Attr.t()))
  end

  validates(:visibility, inclusion: Kojin.Rust.allowed_visibilities())

  @doc """
  Ensures the name is snake case.
  """
  def valid_name?(name) do
    Atom.to_string(name) |> Kojin.Id.is_snake()
  end

  validates(:name,
    by: [function: &Field.valid_name?/1, message: "Field.name must be snake case"]
  )

  @doc ~s"""
  Create a field with `name`, `type`, `doc` and the following
  `options`:

  - `visibility`: One of `:private`, `:pub`, `:pub_crate`, `:pub_self`

  ## Examples

      iex> import Kojin.Rust.Field
      ...> field(:age, :i32, "Age", visibility: :private) |> String.Chars.to_string
      ~s{
      ///  Age
      age: i32
      } |> String.trim

      iex> import Kojin.Rust.Field
      ...> field(:age, :i32, "Age", [visibility: :pub_crate]) |> String.Chars.to_string
      ~s{
      ///  Age
      pub(crate) age: i32
      } |> String.trim

  """
  @spec field(atom | binary, atom | binary | Type.t(), binary, Keyword.t()) :: Field.t()
  def field(name, type, doc \\ "TODO: Comment field", opts \\ [])
      when (is_binary(name) or is_atom(name)) and is_binary(doc) do
    name = Kojin.require_snake(name)
    defaults = [visibility: :pub, access: nil, attrs: []]
    merged_opts = Kojin.check_args(defaults, opts)

    visibility =
      case merged_opts[:access] do
        # All valid accesses are trying to limit access for encapsulation
        # In this case default visibility should not be :pub, but rather
        # :private or whatever is specified. For example, access of :ro
        # with no supplied :visibility should give :private. access of :ro
        # with :pub_crate specified should give :pub_crate.
        access when access in @valid_accesses ->
          opts[:visibility] || :private

        nil ->
          # No access specified use provided or :pub merged default
          merged_opts[:visibility]
          # _ -> {:error, "Field `access` must be one of (#{@valid_accesses |> Enum.join(", ")})"}
      end

    %Field{
      name: name,
      doc: doc,
      type: Type.type(type),
      access: merged_opts[:access],
      visibility: visibility,
      attrs: merged_opts[:attrs]
    }
  end

  @doc ~s"""
  Given a list of arguments, passes arguments to `field/4`

  ## Examples

      iex> import Kojin.Rust.Field
      ...> field([:age, :i32, "Age", [visibility: :private]]) |> String.Chars.to_string
      ~s{
      ///  Age
      age: i32
      } |> String.trim

      iex> import Kojin.Rust.Field
      ...> field([:age, :i32, "Age", [visibility: :pub_crate]]) |> String.Chars.to_string
      ~s{
      ///  Age
      pub(crate) age: i32
      } |> String.trim

  """
  def field([name, type, doc, opts]), do: Field.field(name, type, doc, opts)
  def field([name, type, doc]), do: Field.field(name, type, doc)
  def field([name, type]), do: Field.field(name, type)

  @spec id_field(atom | binary, binary, keyword) :: any()
  @doc ~S"""
  Given an `id` creates a field with same type as id name.

  ## Examples

      iex> import Kojin.Rust.Field
      ...> id_field(:bank_account, "The Bank Account") |> String.Chars.to_string
      ~s{
      ///  The Bank Account
      pub bank_account: BankAccount
      } |> String.trim

      iex> import Kojin.Rust.Field
      ...> id_field([:bank_account, "The Bank Account"]) |> String.Chars.to_string
      ~s{
      ///  The Bank Account
      pub bank_account: BankAccount
      } |> String.trim

      iex> import Kojin.Rust.{Field, Attr}
      ...> id_field([:bank_account, "The Bank Account", [attrs: [attr("clap(long)")]]]) |> String.Chars.to_string
      ~s{
      ///  The Bank Account
      #[clap(long)]
      pub bank_account: BankAccount
      } |> String.trim



  """
  def id_field(id, doc, opts \\ [])

  def id_field(id, doc, opts), do: field(id, id, doc, opts)
  @spec id_field([atom | binary | keyword, ...]) :: any()
  def id_field([id, doc, opts]), do: field(id, id, doc, opts)
  def id_field([id, doc]), do: field(id, id, doc, [])

  defimpl String.Chars do
    def to_string(field) do
      [
        triple_slash_comment(
          if String.length(field.doc) > 0 do
            "#{field.doc}"
          else
            "TODO: document #{field.name}"
          end
        ),
        field.attrs
        |> Enum.map(fn attr -> external(attr) end)
        |> Enum.join("\n"),
        Field.decl(field)
      ]
      |> Enum.filter(fn item -> item != "" end)
      |> Enum.join("\n")
    end
  end

  @doc ~s"""
  Returns the declaration of the field without the doc comment.

  ## Example

      iex> import Kojin.Rust.Field
      ...> decl(field(:age, :i32, "Age of customer", visibility: :private))
      "age: i32"

  """
  def decl(field) do
    "#{Kojin.Rust.visibility_decl(field.visibility)}#{field.name}: #{to_string(field.type)}"
  end
end
