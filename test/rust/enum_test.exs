defmodule EnumTest do
  use ExUnit.Case

  import Kojin.Rust.SimpleEnum
  import Kojin.Rust.TupleVariant

  test "enum test" do
    e =
      enum(
        :color,
        "The color choices",
        [{:red, "Red"}, {:green, "Green"}, {:blue, "Blue"}],
        has_snake_conversions: true
      )

    values = e.values
    assert e.values == [red: "Red", green: "Green", blue: "Blue"]
    assert e.doc == "The color choices"
    assert String.contains?(decl(e), "pub fn from_snake")
  end
end
