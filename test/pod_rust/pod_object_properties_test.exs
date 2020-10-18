defmodule PodObjectPropertiesTest do
  use ExUnit.Case

  import Kojin.Pod.PodObject
  import Kojin.PodRust.ObjectProperties

  test "add properties" do
    po = pod_object(:foo, "Foo object", [])
    assert po.properties == %{}
    po = add_rust_derivables(po, [:ord])
    assert po.properties == %{rust: %{derivables: [:ord]}}
  end

  test "remove properties" do
    po = pod_object(:foo, "Foo object", [])
    assert po.properties == %{}
    po = add_rust_derivables(po, [:debug, :ord])
    assert po.properties == %{rust: %{derivables: [:debug, :ord]}}
    po = remove_rust_derivables(po, [:debug])
    assert po.properties == %{rust: %{derivables: [:ord]}}
  end

  test "plus properties" do
    po = pod_object(:foo, "Foo object", [])
    assert po.properties == %{}
    po = plus_rust_derivables(po, [:queryable])
    assert Enum.member?(po.properties.rust.derivables, :queryable)
  end

  test "minus properties" do
    po = pod_object(:foo, "Foo object", [])
    assert po.properties == %{}
    po = minus_rust_derivables(po, [:debug])
    assert !Enum.member?(po.properties.rust.derivables, :debug)
  end

  test "with properties" do
    po = pod_object(:foo, "Foo object", [])
    assert po.properties == %{}
    po = with_rust_derivables(po, [:debug])
    assert po.properties == %{rust: %{derivables: [:debug]}}
    assert Enum.member?(po.properties.rust.derivables, :debug)
  end

end
