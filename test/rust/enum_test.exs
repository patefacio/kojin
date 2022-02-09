defmodule EnumTest do
  use ExUnit.Case

  import Kojin.Rust.SimpleEnum
  import Kojin.Rust.Fn
  import Kojin.Rust.TypeImpl
  alias Kojin.Rust.TypeImpl

  test "enum test" do
    e =
      enum(
        :color,
        "The color choices",
        [{:red, "Red"}, {:green, "Green"}, {:blue, "Blue"}],
        has_snake_conversions: true
      )

    assert e.values == [red: "Red", green: "Green", blue: "Blue"]
    assert e.doc == "The color choices"
    assert String.contains?(decl(e), "pub fn from_snake")
  end

  test "enum with impl test" do
    e =
      enum(
        :color,
        "The color choices",
        [{:red, "Red"}, {:green, "Green"}, {:blue, "Blue"}],
        impl: type_impl(:color, [fun(:f, "Function does f")])
      )

    assert e.values == [red: "Red", green: "Green", blue: "Blue"]
    assert e.doc == "The color choices"
    assert String.contains?(TypeImpl.code(e.impl), "Function does f")
  end
end
