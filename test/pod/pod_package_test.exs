defmodule PodPackageTest do
  use ExUnit.Case
  alias Kojin.Pod.PodPackage
  alias Kojin.Pod.PodTypes

  import PodSamples

  test "all_types" do
    assert(
      [:int64, :string, :vaccination, :toy]
      |> Enum.map(fn t -> {:pet_store, PodTypes.pod_type(t)} end)
      |> MapSet.new() == PodPackage.all_types(sample_package())
    )
  end
end
