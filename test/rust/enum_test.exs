defmodule EnumTest do
  use ExUnit.Case

  import Kojin.Rust.SimpleEnum
  import Kojin.Rust.TupleVariant

  test "enum test" do
    # TODO assert s
    inspect(enum(:color, "The color choices", [:red, :green, :blue]))

    tv(:color, 3)
  end
end
