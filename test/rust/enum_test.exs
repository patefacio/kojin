defmodule EnumTest do
  use ExUnit.Case

  import Kojin.Rust.SimpleEnum
  import Kojin.Rust.TupleVariant

  test "enum test" do
    # TODO assert s
    e = enum(:color, "The color choices", [{:red, "Red"}, {:green, "Green"}, {:blue, "Blue"}])

    IO.puts decl(e)

    tv(:color, 3)
  end
end
