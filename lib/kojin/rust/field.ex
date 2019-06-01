defmodule Kojin.Rust.Field do
  @moduledoc """
  Rust _struct_ _field_ definition.
  """

  use TypedStruct
  use Vex.Struct

  alias Kojin.Rust.Field
  alias Kojin.Rust.Type
  alias Kojin.Rust.Utils
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
    field(:type, String.t(), enforce: true)
    field(:is_by_ref, boolean, default: false)
    field(:access, atom, default: :ro)
    field(:visibility, atom, default: :private)
  end

  @valid_accesses [:ro, :rw, :ia, :wo]
  validates(:access, inclusion: @valid_accesses)

  validates(:visibility, inclusion: Kojin.Rust.allowed_visibilities())

  def valid_name?(name) do
    Atom.to_string(name) |> Kojin.Id.is_snake()
  end

  validates(:name,
    by: [function: &Kojin.Rust.Field.valid_name?/1, message: "Field.name must be snake case"]
  )

  def field(name, type, doc, opts \\ []) do
    import Type
    opts = Keyword.merge([name: name, type: type(type), doc: doc], opts) |> Enum.into(%{})
    struct(Field, opts)
  end

  defimpl String.Chars do
    def to_string(field) do
      triple_slash_comment(
        if String.length(field.doc) > 0 do
          field.doc
        else
          "TODO: document #{field.name}"
        end
      ) <> Field.decl(field)
    end
  end

  def decl(field) do
    "#{Kojin.Rust.visibility_decl(field.visibility)}#{field.name}: #{to_string(field.type)}"
  end
end
