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
  * :type - The rust type of the field
  * :pub - Specifies field should be `pub`
  * :pub_crate - Specifies field should be `pub(crate)`
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:type, String.t(), enforce: true)
    field(:is_by_ref, boolean, default: false)
    field(:access, atom, default: :ro)
    field(:pub, boolean, default: false)
    field(:pub_crate, boolean, default: false)
  end

  @valid_accesses [:ro, :rw, :ia, :wo]
  validates(:access, inclusion: @valid_accesses)

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
    "#{pub_decl(field)}#{field.name}: #{field.type}"
  end
end
