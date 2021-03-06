defmodule Kojin.Pod.PodObject do
  @moduledoc """
  Module for defining plain old data objects, independent of target language
  """

  alias Kojin.Pod.{PodField, PodObject, PodTypeRef, PodTypes}

  use TypedStruct

  @typedoc """
  A plain old data object, with an `id`, a `doc` comment and a
  list of fields.
  """
  typedstruct do
    field(:id, atom, enforce: true)
    field(:doc, String.t())
    field(:fields, list(PodField.t()), default: [])
    field(:properties, map(), default: %{})
  end

  @doc """

  Creates a `Kojin.Pod.PodObject` given:

  - `id`: Identifier for the object
  - `doc`: Documentation on the object type
  - `fields`: List of fields in the object

  ## Examples

      iex> alias Kojin.Pod.{PodObject, PodField, PodType}
      ...> import Kojin.Pod.{PodObject, PodField}
      ...> point = pod_object(:point, "A 2 dimensional point", [
      ...>  pod_field(:x, "Abcissa", :int32),
      ...>  pod_field(:y, "Ordinate", :int32)
      ...> ])
      ...> (%PodObject{
      ...>    id: :point,
      ...>    doc: "A 2 dimensional point",
      ...>    fields: [
      ...>       %PodField{
      ...>          id: :x,
      ...>          doc: "Abcissa",
      ...>          type: %PodType{ id: :int32 }
      ...>       },
      ...>       %PodField{
      ...>          id: :y,
      ...>          doc: "Ordinate",
      ...>          type: %PodType{ id: :int32 }
      ...>       }
      ...>    ]
      ...> } = point) && true
      true

    Converts list of field parameters into list of fields:

      iex> alias Kojin.Pod.{PodObject, PodField, PodType}
      ...> import Kojin.Pod.{PodObject}
      ...> point = pod_object(:point, "A 2 dimensional point", [
      ...>  [:x, "Abcissa", :int32],
      ...>  [:y, "Ordinate", :int32]
      ...> ])
      ...> (%PodObject{
      ...>    id: :point,
      ...>    doc: "A 2 dimensional point",
      ...>    fields: [
      ...>       %PodField{
      ...>          id: :x,
      ...>          doc: "Abcissa",
      ...>          type: %PodType{ id: :int32 }
      ...>       },
      ...>       %PodField{
      ...>          id: :y,
      ...>          doc: "Ordinate",
      ...>          type: %PodType{ id: :int32 }
      ...>       }
      ...>    ]
      ...> } = point) && true
      true
  """
  def pod_object(id, doc, fields, opts \\ []) when is_atom(id) and is_binary(doc) do
    opts =
      Kojin.check_args(
        [
          properties: %{}
        ],
        opts
      )

    %PodObject{
      id: id,
      doc: doc,
      fields: fields |> Enum.map(fn field -> PodField.pod_field(field) end),
      properties: opts[:properties]
    }
  end

  @doc """
  Returns all distinct types referenced in the `PodObject` (non-recursive).

  Note: Array is not represented as a type

  ## Examples

      iex> import Kojin.Pod.{PodObject, PodField, PodArray}
      ...> all_types(pod_object(:x, "x", [ pod_field(:f, "f", array_of(:t))]))
      MapSet.new([Kojin.Pod.PodTypes.pod_type(:t)])

  """
  def all_types(%PodObject{} = pod_object) do
    pod_object.fields
    |> Enum.reduce(MapSet.new(), fn pod_field, acc ->
      # put in the referred type if there is one, or the standard type
      MapSet.put(acc, PodTypes.ref_type(pod_field.type) || pod_field.type)
    end)
  end

  @doc """
  Returns all distinct ref types referenced in the `PodObject` (non-recursive)
  """
  def all_ref_types(%PodObject{} = pod_object) do
    for(
      %PodTypeRef{} = elm <- Enum.map(all_types(pod_object), fn t -> PodTypes.ref_type(t) end),
      do: elm
    )
    |> MapSet.new()
  end
end
