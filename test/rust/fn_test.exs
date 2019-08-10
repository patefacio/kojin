defmodule FnTest do
  use ExUnit.Case
  import Kojin
  import Kojin.Rust.{Type, Fn, Parm, ToCode}
  alias Kojin.Rust.Fn
  import TestHelper

  test "fn sigs" do
    doc = "A simple function"

    f = fun("f", doc, [])
    assert f.name == :f
    assert f.doc == doc
    parm1 = parm(:a, :A, "An a")

    f = fun(:f, doc, [parm1], :i32)
    assert Enum.at(f.parms, 0) == parm1
    assert f.return == type(:i32)
    assert f.return_doc == ""

    f = fun(:f, doc, [parm1], :i32, "calculated f")
    assert f.return_doc == "calculated f"

    mparm1 = parm(:a, :A, doc: "An a", mut: true)
    f = fun(:f, doc, [mparm1])
    assert String.contains?(Fn.code(f), "f(mut a: A)")

    assert to_code(f) == "#{f}"
  end

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
             ///   * `a` - Your basic A
             #[inline]
             fn do_it(a: A) {
             }
             """)
  end

  test "fn with args and return" do
    dark_compare(
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
      ),
      """
      ///  Foo does your basic `foo` stuff.
      ///
      ///   * `a` - Your basic A
      ///   * `b` - The `b` to foo
      ///   * `c` - Required
      ///   * _return_ - TODO: document return
      #[inline]
      fn do_it(a: A, mut b: B, c: C) -> i32 {
      }
      """
    )
  end

  test "fn no args, simplified return" do
    dark_compare(
      fun(:f, "An f.", [], return: {:i32, "Badabing"}),
      "
      ///  An f.
      ///
      ///   * _return_ - Badabing
      fn f() -> i32 {
      }
      "
    )
  end

  test "fn with generic" do
    f =
      fun(
        :do_it,
        "Magic do it function",
        [
          parm(:a, ref(:A, :a), doc: "Your basic A"),
          parm(:b, mref(:B, :b), mut: true, doc: "The `b` to foo"),
          [:c, :C, doc: "Required"],
          [:d, :i32]
        ],
        generic: [
          [:T1, [:T3, bounds: [:a, :b, "Infinite", "Collapsible", "Responsible"]]],
          lifetimes: [:a, :b]
        ],
        return: {:i32, "Foo"},
        inline: true
      )

    dark_compare(f, """
    ///  Magic do it function
    ///
    ///   * `a` - Your basic A
    ///   * `b` - The `b` to foo
    ///   * `c` - Required
    ///   * `d` - TODO: Comment d
    ///   * _return_ - Foo
    #[inline]
    fn<'a, 'b, T1, T3> do_it(a: & 'a A, mut b: & 'b mut B, c: C, d: i32) -> i32
    where
    T3:   'a + 'b + Infinite + Collapsible + Responsible {
    }
    """)
  end
end
