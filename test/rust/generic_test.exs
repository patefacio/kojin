defmodule GenericTest do
  use ExUnit.Case
  import Kojin
  import ExUnit.CaptureIO
  alias Kojin.Rust.Generic
  alias Kojin.Rust.TypeParm

  test "type parm" do
    assert dark_matter(TypeParm.code(TypeParm.type_parm(:T, default_type: :i32))) ==
             dark_matter("T = i32")
  end

  test "type parm with bounds" do
    assert TypeParm.type_parm(:T, default_type: :i32, bounds: [:Foo]).bounds ==
             ["Foo"]
  end

  test "generic no lifetimes" do
    assert dark_matter(Generic.code(Generic.generic([[:T1], [:T2, [default_type: :i64]]]))) ==
             dark_matter("<T1, T2 = i64>")
  end

  test "generic with lifetimes" do
    assert dark_matter(
             Generic.code(
               Generic.generic([[:T1], [:T2, [default_type: :i64]]], lifetimes: [:a, :b])
             )
           ) ==
             dark_matter("<'a, 'b, T1, T2 = i64>")
  end

  test "generic with lifetimes and simple type" do
    assert dark_matter(
             Generic.code(
               Generic.generic([:T1, [:T2, [default_type: :i64]]], lifetimes: [:a, :b])
             )
           ) ==
             dark_matter("<'a, 'b, T1, T2 = i64>")
  end


end
