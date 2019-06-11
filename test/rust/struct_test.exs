defmodule StructTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  import Kojin.Rust.Struct

  test "s" do
    IO.puts(struct(:s, "This is an s", []))
  end
end
