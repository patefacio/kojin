defmodule Kojin.Rust.Struct do
  @moduledoc """
  Rust _struct_ definition.
  """

  alias Kojin.Rust.Field
  alias Kojin.Rust.Struct
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
    IO.puts("MAKING field #{inspect(opts)}\n-----\n")
    apply(Field, :field, opts)
  end

  def _make_field(field = %Field{}) do
    field
  end

  def struct(name, doc, fields, opts \\ []) do
    defaults = [visibility: :private, derivables: []]

    opts = Keyword.merge(defaults, opts)

    result = %Struct{
      name: name,
      doc: doc,
      fields: Enum.map(fields, &Struct._make_field/1),
      visibility: opts[:visibility],
      derivables: opts[:derivables]
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
    def to_string(struct) do
      triple_slash_comment(
        if String.length(struct.doc) > 0 do
          struct.doc
        else
          "TODO: document #{struct.name}"
        end
      ) <> Struct.decl(struct)
    end
  end

  def decl(struct) do
    import Kojin.Rust
    import Kojin.Id

    visibility = visibility_decl(struct.visibility)
    derivables_decl = derivables_decl(struct.derivables)

    """
    #{String.trim(triple_slash_comment(struct.doc))}
    #{derivables_decl}#{visibility}struct #{cap_camel(struct.name)} {
    #{
      indent_block(
        struct.fields
        |> Enum.map(&to_string/1)
        |> Enum.join(",\n")
      )
    }
    }
    """
  end
end
