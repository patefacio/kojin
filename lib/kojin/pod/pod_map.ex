defmodule Kojin.Pod.PodMap do
  @moduledoc """
  Represents a map keyed by string and some other `Kojin.Pod.PodType`
  """
  use TypedStruct

  alias Kojin.Pod.{PodMap, PodArray, PodType, PodTypeRef, PodTypes}

  @typedoc """
  Defines a map keyed by string and value of some other `Kojin.Pod.PodType`
  """
  typedstruct enforce: true do
    field(:key_doc, String.t() | nil)
    field(:value_type, PodType.t() | PodTypeRef.t())
  end

  def map_of(type, key_doc \\ nil)

  @doc """
  Returns a `Kojin.Pod.PodMap` with the type of values specified
  by `value_type` and documentation (`key_doc`) for the string key

  ## Examples

    Passing a known pod type identified by atom (e.g. :i32, :i64)
    creates a map of string to that type.

      iex> alias Kojin.Pod.{PodMap, PodTypes}
      ...> PodMap.map_of(:i32, "Keyed by name of person")
      %Kojin.Pod.PodMap{
              key_doc: "Keyed by name of person",
              value_type: %Kojin.Pod.PodTypeRef{type_id: :i32, type_path: []}
            }

    Passing a type that *references* another `PodObject`, `PodArray` or
    `PodMap` treats that named reference as a `PodTypeRef` to that
    type. In this case, the type `:person` is defined elsewhere, likely
    with a call to `pod_object(:person, ...)`

      iex> alias Kojin.Pod.{PodMap, PodTypes}
      ...> import Kojin.Pod.PodTypeRef
      ...> PodMap.map_of(pod_type_ref("root.person"), "Person keyed by name of person")
      %Kojin.Pod.PodMap{
              key_doc: "Person keyed by name of person",
              value_type: %Kojin.Pod.PodTypeRef{type_id: :person, type_path: [:root]}
            }

    Passing a type that is an atom turns it into a `PodTypeReference`.

      iex> alias Kojin.Pod.{PodMap, PodTypes}
      ...> PodMap.map_of(:person, "Person keyed by name of person")
      %Kojin.Pod.PodMap{
              key_doc: "Person keyed by name of person",
              value_type: %Kojin.Pod.PodTypeRef{type_id: :person, type_path: []}
            }

    Passing `Kojin.Pod.PodMap` in just returns the pod map.

      iex> alias Kojin.Pod.{PodMap, PodTypes}
      ...> PodMap.map_of(PodMap.map_of(:person, "Person keyed by name of person"))
      %Kojin.Pod.PodMap{
              key_doc: "Person keyed by name of person",
              value_type: %Kojin.Pod.PodTypeRef{type_id: :person, type_path: []}
            }
  """

  @spec map_of(String.t() | atom(), String.t() | nil) :: PodMap.t()
  def map_of(item_type, key_doc) when is_binary(item_type) or is_atom(item_type) do
    %PodMap{value_type: PodTypes.pod_type(item_type), key_doc: key_doc}
  end

  @spec map_of(PodType.t(), any) :: PodMap.t()
  def map_of(%PodType{} = item_type, key_doc) do
    %PodMap{value_type: item_type, key_doc: key_doc}
  end

  @spec map_of(PodTypeRef.t(), String.t() | nil) :: PodMap.t()
  def map_of(%PodTypeRef{} = pod_type_ref, key_doc) do
    %PodMap{value_type: pod_type_ref, key_doc: key_doc}
  end

  @spec map_of(PodMap.t(), nil) :: PodMap.t()
  def map_of(%PodMap{} = pod_map, nil), do: pod_map

  @spec map_of(PodArray.t(), nil | String.t()) :: PodMap.t()
  def map_of(%PodArray{} = pod_array, key_doc) do
    %PodMap{value_type: pod_array, key_doc: key_doc}
  end
end
