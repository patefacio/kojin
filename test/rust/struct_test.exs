defmodule StructTest do
  use ExUnit.Case
  import Kojin.Rust.{Struct, Field, ToCode}

  test "s" do
    s =
      struct(:s, "This is an ssssss", [
        field(:f, :i32, "Field 1"),
        [:f2, :i32, "Field 2"],
        [:f3, "i32"]
      ])

    IO.puts(to_code(s))
  end
end
