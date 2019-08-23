defmodule PodTest do
  use ExUnit.Case
  alias Kojin.PodObject
  import Kojin.PodField

  test "pod object" do
    p1 = %PodObject{name: "foo", doc: "Goo"}
    p2 = %PodObject{name: "foo", doc: "Good"}

    # assert (p1 == p2)

    z = %{p1 => "p1", p2 => "p2"}
  end

  test "pod field" do
    pf = pod_field(:foo_bar, "sample foo bar field", optional?: true)
  end
end
