defmodule ParmTest do
  use ExUnit.Case
  import Kojin.Rust.Parm

  test "mutable test" do
    parm(:foo, "Result<T,Err>", mut: true)
    # TODO assert
  end
end
