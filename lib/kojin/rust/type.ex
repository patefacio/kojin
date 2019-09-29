defmodule Kojin.Rust.Type do
  @moduledoc """
  Rust _type_.

  Lifetimes are not part of the type. However, when specifying types
  in the context of a function signature or any reference type in a
  struct definition, lifetimes may _annotate_ the reference or type.

  So as a convenience, the type allows for a lifetime association.
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
    field(:mref?, boolean, default: false)
    field(:ref?, boolean, default: false)
    field(:lifetime, atom, default: nil)
  end

  def type(nil), do: nil
  def type(:i8), do: %Type{base: "i8", primitive?: true}
  def type(:i16), do: %Type{base: "i16", primitive?: true}
  def type(:i32), do: %Type{base: "i32", primitive?: true}
  def type(:i64), do: %Type{base: "i64", primitive?: true}

  def type(:u8), do: %Type{base: "u8", primitive?: true}
  def type(:u16), do: %Type{base: "u16", primitive?: true}
  def type(:u32), do: %Type{base: "u32", primitive?: true}
  def type(:u64), do: %Type{base: "u64", primitive?: true}
  def type(:usize), do: %Type{base: "usize", primitive?: true}

  def type(:f32), do: %Type{base: "f32", primitive?: true}
  def type(:f64), do: %Type{base: "f64", primitive?: true}
  def type(:unit), do: %Type{base: "()", primitive?: true}
  def type(:str), do: %Type{base: "str", primitive?: true}
  def type(:string), do: %Type{base: "String", primitive?: true}
  def type(:String), do: type(:string)
  def type(:bool), do: %Type{base: "bool", primitive?: true}

  def type(:char), do: %Type{base: "char", primitive?: true}

  @doc """
  Returns rust type corresponding to type.
  """
  def type(type) when is_binary(type),
    do: %Type{base: type, primitive?: false}

  def type(%Type{} = type), do: type

  def type(type) when is_atom(type), do: type(Kojin.Id.cap_camel(Atom.to_string(type)))

  @doc ~S"""
  Creates a reference to provided type `t`.

  ## Examples

      iex> Kojin.Rust.Type.ref(:i32)
      ...> |> String.Chars.to_string()
      "& i32"
      
  """
  def ref(t, lifetime \\ nil),
    do: %Type{primitive?: false, referrent: type(t), ref?: true, lifetime: lifetime}

  @doc """
  Create type that is *mutable reference* to `t` with specified `lifetime`.

    ## Examples

      iex> Kojin.Rust.Type.mref(:i32)
      ...> |> String.Chars.to_string()
      "& mut i32"
      
  """
  def mref(t, lifetime \\ nil),
    do: %Type{primitive?: false, referrent: type(t), mref?: true, lifetime: lifetime}

  defp lifetime(t) do
    cond do
      t.lifetime == nil -> ""
      true -> " '#{t.lifetime}"
    end
  end

  def code(t, with_lifetimes \\ true) do
    lifetime =
      if with_lifetimes do
        lifetime(t)
      else
        ""
      end

    cond do
      t.base != nil -> t.base
      t.mref? -> "&#{lifetime} mut #{code(t.referrent, with_lifetimes)}"
      t.ref? -> "&#{lifetime} #{code(t.referrent, with_lifetimes)}"
      true -> raise "A type must be a named {type, mref, or ref} -> #{inspect(t)}"
    end
  end

  defimpl String.Chars do
    def to_string(t) do
      Type.code(t)
    end
  end
end
