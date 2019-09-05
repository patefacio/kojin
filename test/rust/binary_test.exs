defmodule BinaryTest do
  use ExUnit.Case

  import Kojin.Rust.{Arg, Binary}

  test "arg basics" do
    arg(:first_name, "The first name of the person", short: "f", type: :i32)
    |> IO.inspect()
  end
end
