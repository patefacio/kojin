defmodule X do
  use TypedStruct

  typedstruct enforce: true do
    field(:name, String.t())
    field(:age, integer())
    field(:weight, number())
  end
end

defmodule FnTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  import Kojin
  import Kojin.Rust.Type
  alias Kojin.Rust.Fn
  import Kojin.Rust.Fn
  import Kojin.Rust.Generic
  import Kojin.Rust.Parm
  import Kojin.Utils

  test "fn with no args" do
    assert dark_matter(
             fun(
               :do_it,
               "Foo with no return.",
               [],
               inline: true
             )
           ) ==
             dark_matter("""
             ///  Foo with no return.
             #[inline]
             fn do_it() {
             }
             """)
  end

  test "fn with args and no return" do
    assert dark_matter(
             fun(
               :do_it,
               "Foo with no return.",
               [
                 parm(:a, :A, doc: "Your basic A")
               ],
               inline: true
             )
           ) ==
             dark_matter("""
             ///  Foo with no return.
             ///
             ///   * `a` Your basic A
             #[inline]
             fn do_it(a: A) {
             }
             """)
  end

  test "fn with args and return" do
    assert dark_matter(
             fun(
               :do_it,
               "Foo does your basic `foo` stuff.",
               [
                 parm(:a, :A, doc: "Your basic A"),
                 parm(:b, :B, mut: true, doc: "The `b` to foo"),
                 parm(:c, :C, doc: "Required")
               ],
               return: :i32,
               inline: true
             )
           ) ==
             dark_matter("""
             ///  Foo does your basic `foo` stuff.
             ///
             ///   * `a` Your basic A
             ///   * `b` The `b` to foo
             ///   * `c` Required
             #[inline]
             fn do_it(a: A, mut b: B, c: C) -> i32 {
             }
             """)
  end

  test "fn with generic" do
    IO.puts(
      fun(
        :do_it,
        "Magic do it function",
        [
          parm(:a, ref(:A, :a), doc: "Your basic A"),
          parm(:b, mref(:B, :b), mut: true, doc: "The `b` to foo"),
          parm(:c, :C, doc: "Required")
        ],
        generic: [
          [:T1, [:T3, bounds: [:a, :b, "Infinite", "Collapsible", "Responsible"]]],
          lifetimes: [:a, :b]
        ],
        return: :i32,
        inline: true
      )
      |> String.Chars.to_string()
    )
  end

  test "struct play" do
    a = %X{name: :dan, weight: 75.0, age: 23}
    b = %X{weight: 75.0, name: :dan, age: 23}
    c = %X{weight: 75.0, name: :adam, age: :two}
    IO.puts(inspect(a))
    IO.puts(inspect(c))
    IO.puts(a == b)
    IO.puts(a < b)
    IO.puts(a > b)

    IO.puts(a < c)
    IO.puts(c < a)
  end
end
