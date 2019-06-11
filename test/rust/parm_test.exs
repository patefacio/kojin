defmodule ParmTest do
  use ExUnit.Case
  import Kojin.Rust.Parm
  import ExUnit.CaptureIO

  test "mutable test" do
    IO.puts(parm(:foo, "Result<T,Err>", mutable?: true))
  end
end
