defmodule Kojin.Rust.Struct do
  @moduledoc """
  Rust _struct_ definition.
  """

  alias Kojin.Rust.{Field, Struct, TypeImpl}
  alias Kojin.Utils
  import Utils

  use TypedStruct
  use Vex.Struct

  @typedoc """
  A rust _struct_.

  * :name - The field name in _snake case_
  * :doc - Documentation for struct
  * :fields - List of struct fields
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:fields, list(Field.t()), default: [])
    field(:derivables, list(atom), default: [])
    field(:visibility, atom, default: :private)
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
    defaults = [visibility: :private, derivables: [], impl: nil]

    opts = Keyword.merge(defaults, opts)

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
      doc: doc,
      fields: Enum.map(fields, &Struct._make_field/1),
      visibility: opts[:visibility],
      derivables: opts[:derivables],
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
    def to_code(struct), do: Struct.decl(struct)
  end

  def decl(struct) do
    import Kojin.Rust
    import Kojin.Id

    visibility = visibility_decl(struct.visibility)
    derivables_decl = derivables_decl(struct.derivables)

    impl =
      if(struct.impl) do
        "#{struct.impl}"
      else
        ""
      end

    join_content(
      [
        join_content([
          String.trim(triple_slash_comment(struct.doc)),
          "#{derivables_decl}#{visibility}struct #{cap_camel(struct.name)} {",
          indent_block(
            struct.fields
            |> Enum.map(&to_string/1)
            |> Enum.join(",\n")
          ),
          "}"
        ]),
        impl
      ],
      "\n\n"
    )
  end
end
