defmodule Kojin.Rust.AssociatedType do
  use TypedStruct
  alias Kojin.Rust.{AssociatedType, Bounds}

  @typedoc """
  A rust _associated type_, which appears in traits.
  """
  typedstruct enforce: true do
    field(:id, String)
    field(:name, String)
    field(:doc, String.t())
    field(:bounds, list(Bounds.t()), default: [])
  end

  @doc """
  Returns or creates by calling `associated_type` the `AssociatedType`

  ## Examples

      iex> import Kojin.Rust.AssociatedType
      ...> associated_type(associated_type(:some_type, "The type stored in trait"))
      %Kojin.Rust.AssociatedType{
        id: "some_type",
        name: "SomeType",
        doc: "The type stored in trait"
      }

      iex> import Kojin.Rust.AssociatedType
      ...> associated_type([:some_type, "The type stored in trait"])
      %Kojin.Rust.AssociatedType{
        id: "some_type",
        name: "SomeType",
        doc: "The type stored in trait",
        bounds: []
      }

  """
  def associated_type(%AssociatedType{} = associated_type), do: associated_type
  def associated_type([id, doc | bounds]), do: associated_type(id, doc, bounds)

  @doc """
  Represents an `Associated Type` used to model type requirements
  of traits.

  ## Examples

      iex> import Kojin.Rust.AssociatedType
      ...> associated_type(:some_type, "The type stored in trait")
      %Kojin.Rust.AssociatedType{
        id: "some_type",
        name: "SomeType",
        doc: "The type stored in trait",
        bounds: []
      }

  """
  def associated_type(id, doc, bounds \\ [])

  def associated_type(id, doc, bounds) when is_atom(id) and is_binary(doc) do
    associated_type(Atom.to_string(id), doc, bounds)
  end

  def associated_type(id, doc, bounds) when is_binary(id) and is_binary(doc) do
    Kojin.require_snake(id)

    %AssociatedType{
      id: id,
      name: Kojin.Id.cap_camel(id),
      doc: doc,
      bounds: Enum.map(bounds, fn bounds -> Kojin.Rust.Bounds.bounds(bounds) end)
    }
  end

  defimpl String.Chars do
    def to_string(associated_type) do
      bounds =
        if(!Enum.empty?(associated_type.bounds)) do
          ": #{Enum.join(associated_type.bounds, ", ")}"
        else
          ""
        end

      [
        Kojin.Utils.triple_slash_comment(associated_type.doc),
        "type #{associated_type.name} #{bounds};"
      ]
      |> Enum.join("\n")
    end
  end
end
