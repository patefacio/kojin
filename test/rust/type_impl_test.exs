defmodule TypeImplTest do
  use ExUnit.Case
  doctest Kojin.Rust.TypeImpl

  import Kojin.Rust.{TypeImpl, Fn}

  test "type impl test" do
    t = type_impl("FooStruct", [fun(:f1, "Function 1")])
    IO.puts("#{t}")
  end
end