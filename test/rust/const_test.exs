defmodule ConstTest do
  use ExUnit.Case
  import Kojin
  import Kojin.Rust.Const
  import Kojin.Utils

  test "const decl test" do
    c = const(:foo, "This is a foo", :i32, 234)

    assert dark_matter(to_string(c)) ==
             dark_matter("""
             ///  This is a foo
             const FOO i32 = 234;
             """)

    assert dark_matter(to_string(const(:goo, "A goobar", "Result<T,E>", 22))) ==
             dark_matter("""
             /// A goobar
             const GOO Result<T,E> = 22; 
             """)
  end
end
