defmodule Kojin.Rust.Trait do
  @moduledoc """
  Rust _trait_ definition.
  """

  alias Kojin.Rust.Fn
  use TypedStruct
  use Vex.Struct

  @typedoc """
  A rust _module_.
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:functions, list(Fn.t()), default: [])
  end
end
