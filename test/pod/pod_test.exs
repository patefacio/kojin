defmodule PodTest do
  use ExUnit.Case
  alias Kojin.PodObject
  import Kojin.PodField

  test "pod object" do
    p1 = %PodObject{name: "foo", doc: "Goo"}
    p2 = %PodObject{name: "foo", doc: "Good"}

    # assert (p1 == p2)

    %{p1 => "p1", p2 => "p2"}
  end

  test "pod field" do
    pod_field(:foo_bar, "sample foo bar field")
    # TOD Assert pod_field
  end
end
