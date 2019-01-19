defmodule Kojin.Rust.Fn do
  @moduledoc """
  Rust _fn_ definition.
  """

  use TypedStruct
  use Vex.Struct

  @typedoc """
  A rust _module_.
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
  end
end
