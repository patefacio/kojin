defmodule Kojin.Rust.Module do
  @moduledoc """
  Rust _module_ definition.
  """

  alias Kojin.Rust.Struct
  alias Kojin.Rust.Module
  use TypedStruct
  use Vex.Struct

  @typedoc """
  A rust _module_.
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:modules, list(Module.t()), default: [])
    field(:structs, list(Struct.t()), default: [])
  end
end
