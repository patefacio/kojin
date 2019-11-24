defmodule PodObjectTest do
  use ExUnit.Case
  alias Kojin.Pod.PodObject
  alias Kojin.Pod.PodTypes

  import PodSamples

  test "all_types" do
    assert(
      [:int64, :string, :vaccination, :toy]
      |> Enum.map(fn t -> PodTypes.pod_type(t) end)
      |> MapSet.new() == PodObject.all_types(sample_object())
    )
  end

  test "all_ref_types" do
    assert(
      [:vaccination, :toy]
      |> Enum.map(fn t -> PodTypes.pod_type(t) end)
      |> MapSet.new() == PodObject.all_ref_types(sample_object())
    )
  end
end
