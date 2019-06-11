defmodule Kojin.Rust.Type do
  @moduledoc """
  Rust _type_.
  """

  alias Kojin.Rust.Type
  use TypedStruct
  use Vex.Struct

  @typedoc """
  A rust _type_.

  * :base
  """
  typedstruct do
    field(:base, String.t())
    field(:primitive?, boolean, default: false)
    field(:referrent, Type.t())
    field(:mref, boolean, default: false)
    field(:ref, boolean, default: false)
  end

  @doc """
  Returns rust type corresponding to type.
  """
  def type(type) when is_atom(type) do
    if type == nil do
      nil
    else
      {base, primitive?} =
        case type do
          :char -> {"char", "char", true}
          # signed ints
          :i8 -> {"i8", true}
          :i16 -> {"i16", true}
          :i32 -> {"i32", true}
          :i64 -> {"i64", true}
          # unsigned ints
          :u8 -> {"u8", true}
          :u16 -> {"u16", true}
          :u32 -> {"u32", true}
          :u64 -> {"u64", true}
          # floats
          :f32 -> {"f32", true}
          :f64 -> {"f64", true}
          :unit -> {"()", true}
          :str -> {"str", true}
          s when s in [:string, :String] -> {"String", true}
          atom -> {Atom.to_string(atom), false}
        end

      %Type{base: base, primitive?: primitive?}
    end
  end

  def type(%Type{} = type), do: type
  def type(type) when is_binary(type), do: type(String.to_atom(type))

  def ref(t), do: %Type{ primitive?: false, referrent: type(t), ref: true }
  def mref(t), do: %Type{ primitive?: false, referrent: type(t), mref: true }

  def code(t) do
    cond do
      (t.base != nil) -> t.base
      t.mref -> "& mut #{code(t.referrent)}"
      t.ref -> "& #{code(t.referrent)}"
      true -> raise "A type must be a named {type, mref, or ref} -> #{inspect t}"
    end
  end

  defimpl String.Chars do
    def to_string(t) do
      Type.code(t)
    end
  end

end
