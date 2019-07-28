defmodule StructTest do
  use ExUnit.Case
  import Kojin.Rust.Struct
  import Kojin.Rust.Field

  test "s" do
    IO.puts(
      struct(:s, "This is an ssssss", [
        field(:f, :i32, "Field 1"),
        [:f2, :i32, "Field 2"],
        [:f3, "i32"]
      ])
    )
  end
end
