defmodule Kojin.Rust.Struct do
  @moduledoc """
  Rust _struct_ definition.
  """

  alias Kojin.Rust.{Field, Struct, TypeImpl, Generic}
  alias Kojin.Utils
  import Utils
  import Kojin.Id

  use TypedStruct
  use Vex.Struct

  @typedoc """
  A rust _struct_.

  * :name - The field name in _snake case_
  * :doc - Documentation for struct
  * :fields - List of struct fields
  """
  typedstruct enforce: true do
    field(:name, atom)
    field(:type_name, String.t())
    field(:doc, String.t())
    field(:fields, list(Field.t()), default: [])
    field(:derivables, list(atom), default: [])
    field(:visibility, atom, default: :private)
    field(:generic, Generic.t(), default: nil)
    field(:impl, TypeImpl.t() | nil, default: nil)
  end

  validates(:visibility, inclusion: Kojin.Rust.allowed_visibilities())

  validates(:derivables,
    by: [
      function: &Kojin.Rust.valid_derivables?/1,
      message: "Derivables must be in #{inspect(Kojin.Rust.allowed_derivables(), pretty: true)}"
    ]
  )

  validates(:name,
    by: [function: &Kojin.Rust.valid_name/1, message: "Struct.name must be snake case"]
  )

  def _make_field(opts) when is_list(opts) do
    Field.field(opts)
  end

  def _make_field(field = %Field{}) do
    field
  end

  @spec struct(String.t() | atom, String.t(), list(Field.t()), keyword) :: Kojin.Rust.Struct.t()
  def struct(name, doc, fields, opts \\ []) do
    defaults = [visibility: :private, derivables: [], impl: nil, impl?: false, generic: nil]

    opts = Kojin.check_args(defaults, opts)

    impl =
      if(opts[:impl]) do
        TypeImpl.type_impl(opts[:impl])
      else
        if(!opts[:impl] && Keyword.get(opts, :impl?)) do
          TypeImpl.type_impl(name)
        else
          nil
        end
      end

    result = %Struct{
      name: name,
      type_name: cap_camel(name),
      doc: doc,
      fields: Enum.map(fields, &Struct._make_field/1),
      visibility: opts[:visibility],
      derivables: opts[:derivables],
      generic: if(opts[:generic] != nil, do: Generic.generic(opts[:generic])),
      impl: impl
    }

    if(!Vex.valid?(result)) do
      raise ArgumentError,
        message: """
        Invalid `struct`:
        #{inspect(result, pretty: true)}
        ------- Struct Validations ---
        #{inspect(Vex.results(result), pretty: true)}
        """
    end

    result
  end

  defimpl String.Chars do
    def to_string(struct), do: Struct.decl(struct)
  end

  defimpl Kojin.Rust.ToCode do
    @spec to_code(Struct.t()) :: binary
    def to_code(struct), do: Struct.decl(struct)
  end

  @doc """
  Creates a _public_ `Kojin.Rust.Struct` by forwarding to `Kojin.Rust.Struct.struct` with
  extra option `[visibility: :pub]`
  """
  @spec pub_struct(String.t() | atom, String.t(), list(Field.t()), keyword) ::
          Kojin.Rust.Struct.t()
  def pub_struct(name, doc, fields, opts \\ []) do
    struct(name, doc, fields, Keyword.merge(opts, visibility: :pub))
  end

  def decl(struct) do
    import Kojin.{Id, Rust.Utils}

    visibility = Kojin.Rust.visibility_decl(struct.visibility)
    derivables_decl = Kojin.Rust.derivables_decl(struct.derivables)

    {generic, bounds_decl} =
      if(struct.generic) do
        {Generic.code(struct.generic), Generic.bounds_decl(struct.generic)}
      else
        {"", ""}
      end

    join_content(
      [
        join_content([
          String.trim(triple_slash_comment(struct.doc)),
          derivables_decl,
          "#{visibility}struct #{cap_camel(struct.name)}#{generic} {",
          indent_block(
            struct.fields
            |> Enum.map(&to_string/1)
            |> Enum.join(",\n")
          ),
          "}"
        ]),
        announce_section("struct impl", struct.impl)
      ],
      "\n\n"
    )
  end
end
