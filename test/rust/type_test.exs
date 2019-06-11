defmodule TypeTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  import Kojin.Rust.Type

  test "s" do
    IO.puts(type(:i32))
    IO.puts(type(:Result))

    IO.puts(mref(ref(mref(:i32))))
  end
end
