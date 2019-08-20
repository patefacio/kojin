defmodule TypeTest do
  use ExUnit.Case
  import Kojin.Rust.Type
  alias Kojin.Rust.Type

  test "s" do
    import Type

    [
      :i8,
      :i16,
      :i32,
      :i64,
      :u8,
      :u16,
      :u32,
      :u64,
      :f32,
      :f64,
      :str,
      :String,
      :char
    ]
    |> Enum.each(fn t_atom ->
      t = type(t_atom)
      t_code = code(t)
      assert t_code == t_code
      assert %Type{base: t_code, primitive?: true, ref?: false, mref?: false} = t

      ref = ref(t_atom)
      assert %Type{referrent: t, primitive?: false, ref?: true, mref?: false} = ref
      assert code(ref) == "& #{t}"

      ref = ref(t_atom, :a)
      assert %Type{referrent: t, primitive?: false, ref?: true, mref?: false, lifetime: :a} = ref
      assert code(ref) == "& 'a #{t}"

      mref = mref(t_atom)
      assert %Type{referrent: t, primitive?: false, ref?: false, mref?: true} = mref
      assert code(mref) == "& mut #{t_code}"

      mref = mref(t_atom, :a)
      assert %Type{referrent: t, primitive?: false, ref?: false, mref?: true, lifetime: :a} = mref
      assert code(mref) == "& 'a mut #{t_code}"
    end)

    assert code(type(:some_class)) == "SomeClass"

    [
      :result,
      "Result<T>"
    ]
    |> Enum.each(fn type_literal ->
      t = type(type_literal)
      t_code = code(t)
      assert t_code == t_code
      assert %Type{primitive?: false, base: t_code, ref?: false, mref?: false} = t

      assert code(ref(type_literal)) == "& #{t_code}"
      assert code(mref(type_literal)) == "& mut #{t_code}"
      assert code(ref(type_literal, :b)) == "& 'b #{t_code}"
      assert code(mref(type_literal, :b)) == "& 'b mut #{t_code}"
    end)
  end
end
