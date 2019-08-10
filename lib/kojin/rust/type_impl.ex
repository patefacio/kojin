defmodule Kojin.Rust.TypeImpl do
  use TypedStruct
  alias Kojin.Rust.Type

  typedstruct do
    field(:type, Type.t(), enforce: true)
  end
end
