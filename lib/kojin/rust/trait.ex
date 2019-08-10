defmodule Kojin.Rust.Trait do
  @moduledoc """
  Rust _trait_ definition.
  """

  alias Kojin.Rust.Trait
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

  def trait(name, doc, functions \\ [])

  def trait(name, doc, functions) when is_binary(name),
    do: trait(String.to_atom(name), doc, functions)

  def trait(name, doc, functions) do
    IO.puts("Got name #{inspect(name)}")

    %Trait{
      name: name,
      doc: doc,
      functions: functions
    }
  end
end
