defmodule Kojin.Pod.PodArray do
  @moduledoc """
  Represents an array of some other `Kojin.Pod.PodType`.
  """
  use TypedStruct

  alias Kojin.Pod.{PodArray, PodType, PodTypeRef, PodTypes}

  @typedoc """
  Defines an array of items typed by `item_type` which is a `Kojin.Pod.PodType`.
  """
  typedstruct enforce: true do
    field(:item_type, PodType.t() | PodTypeRef.t())
  end

  @doc """
  Returns a `Kojin.Pod.PodArray` with type of items specified by `item_type`

  ## Examples

      iex> alias Kojin.Pod.{PodArray, PodTypes}
      ...> PodArray.array_of(PodTypes.pod_type(:int32))
      %Kojin.Pod.PodArray{
        item_type: %Kojin.Pod.PodType{
          id: :int32,
          doc: "32 bit integer",
          variable_size?: false,
          package: :std
        }
      }

  """
  @spec array_of(PodType.t()) :: PodArray.t()
  def array_of(%PodType{} = item_type) do
    %Kojin.Pod.PodArray{item_type: item_type}
  end

  @doc """
  Returns a `Kojin.Pod.PodArray` with type specified by the standard type

  ## Examples

      iex> alias Kojin.Pod.{PodArray}
      ...> PodArray.array_of(:int64)
      %Kojin.Pod.PodArray{
        item_type: %Kojin.Pod.PodType{
          id: :int64,
          doc: "64 bit integer",
          variable_size?: false,
          package: :std
        }
      }

  """
  @spec array_of(atom) :: PodArray.t()
  def array_of(item_type) when is_atom(item_type), do: array_of(PodTypes.pod_type(item_type))

  @spec array_of(PodTypeRef.t()) :: PodArray.t()
  def array_of(%PodTypeRef{} = pod_type_ref), do: %PodArray{item_type: pod_type_ref}

  @spec array_of(PodArray.t()) :: PodArray.t()
  def array_of(%PodArray{} = pod_array) do
    %PodArray{item_type: pod_array}
  end
end
