defmodule TypeImplTest do
  use ExUnit.Case

  import Kojin.Rust.{TypeImpl, Fn}

  test "type impl test" do
    type_impl("FooStruct", [fun(:f1, "Function 1")])
    # TODO: add asserts and move to doctest
  end
end
