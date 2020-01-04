defmodule PodEnumPropertiesTest do
  use ExUnit.Case

  import Kojin.Pod.PodEnum
  import Kojin.PodRust.EnumProperties

  test "add properties" do
    pe = pod_enum(:color, "Fundamental colors", [:red, :green, :blue])
    assert pe.properties == %{}
    pe = snake_conversions(pe, true)

    assert pe.properties == %{
             rust: %{
               has_snake_conversions: true
             }
           }
  end
end
