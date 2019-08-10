defmodule Kojin.Rust.TraitImpl do
  use TypedStruct
  alias Kojin.Rust.Trait

  typedstruct do
    field(:trait, Trait.t(), enforce: true)
  end
end
