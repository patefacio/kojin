defmodule Kojin.Rust.Trait do
  @moduledoc """
  Rust _trait_ definition.
  """

  alias Kojin.Rust.{Fn, Trait, ToCode}
  import Kojin.{Id, Utils}
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
    %Trait{
      name: name,
      doc: doc,
      functions: functions
    }
  end

  def trait_name(trait), do: trait.name |> cap_camel

  def code(trait) do
    [
      triple_slash_comment(trait.doc),
      "trait #{trait_name(trait)} {",
      trait.functions
      |> Enum.map(fn fun -> "#{Fn.commented_signature(fun)};" end)
      |> Enum.join("\n")
      |> indent_block,
      "}"
    ]
    |> List.flatten()
    |> Enum.join("\n")
  end

  defimpl(String.Chars, do: def(to_string(trait), do: Trait.code(trait)))

  defimpl ToCode do
    @spec to_code(Trait.t()) :: binary
    def to_code(trait) do
      "#{trait}"
    end
  end
end
