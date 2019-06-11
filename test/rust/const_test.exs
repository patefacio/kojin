defmodule ConstTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  import Kojin.Rust.Const

  test "const decl test" do
    c = const(:foo, "This is a foo", :i32, 234)
    IO.puts(c)

    IO.puts(const(:goo, "A goo", :string, "Foobar"))

    IO.puts(const(:goo, "A goobar", :i32, 22))

    IO.puts(const(:goo, "A goobar", "Result<T,E>", 22))
    IO.puts(const(:goo, "A goobar", "Foo.bar.goo", 2))
  end
end
