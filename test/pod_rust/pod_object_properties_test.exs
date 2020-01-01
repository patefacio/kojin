defmodule PodObjectPropertiesTest do
  use ExUnit.Case

  import Kojin.Pod.PodObject
  import Kojin.PodRust.ObjectProperties

  test "add properties" do
    po = pod_object(:foo, "Foo object", [])
    assert po.properties == %{}
    po = add_derivables(po, [:ord])
    assert po.properties == %{rust: %{derivables: [:ord]}}
  end
end
