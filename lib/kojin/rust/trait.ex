defmodule Kojin.Rust.Trait do
  @moduledoc """
  Rust _trait_ definition.
  """

  alias Kojin.Rust.{Fn, Trait, ToCode}
  import Kojin.{Id, Utils}
  use TypedStruct
  use Vex.Struct

  @typedoc """
  A rust _trait_.
  """
  typedstruct enforce: true do
    field(:name, String)
    field(:id, atom)
    field(:doc, String.t())
    field(:functions, list(Fn.t()), default: [])
    field(:visibility, atom, default: :private)
  end

  @doc """
  Create a `Kojin.Rust.Trait` from an _id_ or a `String`
  `name`, a `doc` comment string and its `functions`.

  ## Examples

      iex> import Kojin.Rust.Trait
      ...> import Kojin
      ...> trait(:empty_trait, "A trait with no functions")
      ...> |> String.Chars.to_string()
      ...> |> dark_matter()
      import Kojin
      ~S[
      ///  A trait with no functions
      trait EmptyTrait {}
      ]
      |> dark_matter()

      iex> import Kojin.Rust.Trait
      ...> import Kojin
      ...> (%Kojin.Rust.Trait{ name: "ThirdPartyTrait<T>"} = trait("ThirdPartyTrait<T>")) && :good
      :good    
  """

  def trait(name, doc \\ nil, functions \\ [], opts \\ [])

  def trait(name, doc, functions, opts) when is_binary(name),
    do: _trait(nil, name, doc, functions, opts)

  def trait(name, doc, functions, opts) when is_atom(name),
    do: _trait(name, cap_camel(name), doc, functions, opts)

  defp _trait(id, name, doc, functions, opts) do
    defaults = [visibility: :private]
    opts = Kojin.check_args(defaults, opts)

    %Trait{
      name: name,
      id: id,
      doc: doc || "TODO: Document trait #{name}",
      functions: functions,
      visibility: opts[:visibility]
    }
  end

  def trait_name(trait), do: trait.name |> cap_camel

  @spec code(Trait.t()) :: binary
  def code(%Trait{} = trait) do
    visibility = Kojin.Rust.visibility_decl(trait.visibility)

    [
      triple_slash_comment(trait.doc),
      "#{visibility}trait #{trait_name(trait)} {",
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
