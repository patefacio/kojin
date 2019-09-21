defmodule Kojin.Rust.Field do
  @moduledoc """
  Rust _struct_ _field_ definition.
  """

  use TypedStruct
  use Vex.Struct

  alias Kojin.Rust.{Field, Type}
  alias Kojin.Utils
  import Utils

  @typedoc """
  A *field* of a _struct_.

  * :name - The field name in _snake case_
  * :doc - Documentation for the field
  * :type - The rust type of the field
  * :visibility - The visibility for the field (eg :pub, :pub(crate), etc)
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:type, Type.t(), enforce: true)
    field(:visibility, atom, default: :private)
  end

  validates(:visibility, inclusion: Kojin.Rust.allowed_visibilities())

  @doc """
  Ensures the name is snake case.
  """
  def valid_name?(name) do
    Atom.to_string(name) |> Kojin.Id.is_snake()
  end

  validates(:name,
    by: [function: &Kojin.Rust.Field.valid_name?/1, message: "Field.name must be snake case"]
  )

  @doc ~s"""
  Create a field with `name`, `type`, `doc` and the following
  `options`:

  - `visibility`: One of `:private`, `:pub`, `:pub_crate`, `:pub_self`

  ## Examples

      iex> import Kojin.Rust.Field
      ...> field(:age, :i32, "Age") |> String.Chars.to_string
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
  @spec field(atom | binary, atom | Type.t(), binary, list) :: Field.t()
  def field(name, type, doc \\ "TODO: Comment field", opts \\ [])
      when (is_binary(name) or is_atom(name)) and is_binary(doc) do
    alias Kojin.Rust.Type

    defaults = [visibility: :private]
    opts = Kojin.check_args(defaults, opts)

    %Field{
      name: name,
      doc: doc,
      type: Type.type(type),
      visibility: opts[:visibility]
    }
  end

  @doc ~s"""
  Given a list of arguments, passes arguments to `field/4`

  ## Examples

      iex> import Kojin.Rust.Field
      ...> field([:age, :i32, "Age"]) |> String.Chars.to_string
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

  defimpl String.Chars do
    def to_string(field) do
      triple_slash_comment(
        if String.length(field.doc) > 0 do
          "#{field.doc}"
        else
          "TODO: document #{field.name}"
        end
      ) <> "\n" <> Field.decl(field)
    end
  end

  @doc ~s"""
  Returns the declaration of the field without the doc comment.

  ## Example

      iex> import Kojin.Rust.Field
      ...> decl(field(:age, :i32, "Age of customer"))
      "age: i32"

  """
  def decl(field) do
    "#{Kojin.Rust.visibility_decl(field.visibility)}#{field.name}: #{to_string(field.type)}"
  end
end
