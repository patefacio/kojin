defmodule ParmTest do
  use ExUnit.Case
  import Kojin.Rust.Parm

  test "mutable test" do
    parm(:foo, "Result<T,Err>", mutable?: true)
    # TODO assert
  end
end
