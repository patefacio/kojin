defmodule EnumTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  import Kojin.Rust.SimpleEnum
  import Kojin.Rust.TupleVariant

  test "enum test" do
    IO.puts(inspect(enum(:color, "The color choices", [:red, :green, :blue])))

    tv(:color, 3)

    IO.puts("TESTING ENUM" <> "goo")
  end
end
