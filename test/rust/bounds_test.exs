defmodule BoundsTest do
  require Logger
  use ExUnit.Case
  alias Kojin.Rust.Bounds

  test "bounds test" do
    assert %Bounds{lifetimes: [:a, :b], traits: ["C"]} = Bounds.bounds([:a, :b, "C"])

    assert %Bounds{lifetimes: [:abc_123, :static], traits: ["C", "D"]} =
             Bounds.bounds(%{lifetimes: [:abc_123, "static"], traits: ["C", :D]})
  end
end
