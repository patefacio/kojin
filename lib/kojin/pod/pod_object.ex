defmodule Kojin.Pod.PodObject do
  @moduledoc """
  Module for defining plain old data objects, independent of target language
  """

  alias Kojin.Pod.{PodField, PodObject}

  use TypedStruct
  use Vex.Struct

  @typedoc """
  A plain old data object, with an `id`, a `doc` comment and a
  list of fields.
  """
  typedstruct do
    field(:id, atom, enforce: true)
    field(:doc, String.t())
    field(:fields, list(PodField.t()), default: [])
  end

  @doc """

  Creates a `Kojin.Pod.PodObject` given:

  - `id`: Identifier for the object
  - `doc`: Documentation on the object type
  - `fields`: List of fields in the object

  ## Examples

      iex> alias Kojin.Pod.{PodObject, PodField}
      ...> point = PodObject.pod_object(:point, "A 2 dimensional point", [
      ...>  PodField.pod_field(:x, "Abcissa", :int32),
      ...>  PodField.pod_field(:y, "Ordinate", :int32)
      ...> ])
      ...> (%Kojin.Pod.PodObject{
      ...>    id: :point,
      ...>    doc: "A 2 dimensional point"
      ...> } = point) && true
      true

    Converts list of field parameters into list of fields:

      iex> alias Kojin.Pod.{PodObject, PodField}
      ...> point = PodObject.pod_object(:point, "A 2 dimensional point", [
      ...>  [:x, "Abcissa", :int32],
      ...>  [:y, "Ordinate", :int32]
      ...> ])
      ...> (%Kojin.Pod.PodObject{
      ...>    id: :point,
      ...>    doc: "A 2 dimensional point",
      ...>    fields: [ %Kojin.Pod.PodField{ id: :x }, %Kojin.Pod.PodField{ id: :y } ]
      ...> } = point) && true
      true
  """
  def pod_object(id, doc, fields) when is_atom(id) and is_binary(doc) do
    %PodObject{
      id: id,
      doc: doc,
      fields: fields |> Enum.map(fn field -> PodField.pod_field(field) end)
    }
  end
end
