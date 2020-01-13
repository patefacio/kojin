defmodule GenericTest do
  use ExUnit.Case
  import Kojin
  alias Kojin.Rust.Generic
  alias Kojin.Rust.TypeParm
  import Generic

  test "type parm" do
    assert dark_matter(TypeParm.code(TypeParm.type_parm(:T, default: :i32))) ==
             dark_matter("T = i32")
  end

  test "type parm with bounds" do
    import TypeParm
    tp = type_parm(:T, default: :i32, bounds: [:static, "Debug"])
    assert "#{tp.bounds}" == "'static + Debug"
  end

  test "generic no lifetimes" do
    assert dark_matter(code(generic(type_parms: [:T1, [:T2, default: :i64]]))) ==
             dark_matter("<T1, T2 = i64>")
  end

  test "generic with lifetimes" do
    assert dark_matter(code(generic(type_parms: [:T1, :T2, :t3], lifetimes: [:a, :b]))) ==
             dark_matter("<'a, 'b, T1, T2, T3>")

    assert dark_matter(
             code(generic(type_parms: [:T1, [:T2, default: :i64]], lifetimes: [:a, :b]))
           ) ==
             dark_matter("<'a, 'b, T1, T2 = i64>")
  end

  test "generic with lifetimes and simple type" do
    assert dark_matter(
             Generic.code(
               Generic.generic(type_parms: [:T1, [:T2, default: :i64]], lifetimes: [:a, :b])
             )
           ) ==
             dark_matter("<'a, 'b, T1, T2 = i64>")
  end
end
