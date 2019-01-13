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
    field(:base, String.t(), enforce: true)
    field(:qualified, String.t(), enforce: true)
    field(:primitive?, boolean, enforce: true)
  end

  def type(type) when is_atom(type) do
    {qualified, base, primitive?} =
      case type do
        :char -> {"char", "char", true}
        # signed ints
        :i8 -> {"i8", "i8", true}
        :i16 -> {"i16", "i16", true}
        :i32 -> {"i32", "i32", true}
        :i64 -> {"i64", "i64", true}
        # unsigned ints     
        :u8 -> {"u8", "u8", true}
        :u16 -> {"u16", "u16", true}
        :u32 -> {"u32", "u32", true}
        :u64 -> {"u64", "u64", true}
        # floats
        :f32 -> {"f32", "f32", true}
        :f64 -> {"f64", "f64", true}
        :unit -> {"()", "()", true}
        :str -> {"str", "str", true}
        :String -> {"std::string::String", "String", true}
        _ -> {"Unknown", "Unknown", false}
      end

    %Type{base: base, qualified: qualified, primitive?: primitive?}
  end
end
