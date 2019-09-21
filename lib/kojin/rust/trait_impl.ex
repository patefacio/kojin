defmodule Kojin.Rust.TraitImpl do
  @moduledoc """
  Responsible for generating _Trait_ _Impls_.

  A `Kojin.Rust.TraitImpl` has definitions for the functions of the trait.
  Rather than store additional function objects, update the
  functions in the `Trait` by adding a body if desired.

  If no body is desired for a `Kojin.Rust.Trait`, code blocks
  will be generated.
  """
  use TypedStruct
  alias Kojin.Rust.{Trait, TraitImpl, Type}
  import Kojin.Utils

  typedstruct enforce: true do
    field(:type, Type.t())
    field(:trait, Trait.t())
    field(:doc, String.t())
  end

  @doc """
  Create a `Kojin.Rust.TraitImpl` from the given `trait`
  and its implementation specific doc comment, `doc`.

  ## Examples

      iex> import Kojin.Rust.{Trait, TraitImpl}
      ...> import Kojin
      ...> trait_impl("ThirdPartyTrait", :i32)
      ...> |> String.Chars.to_string()
      ...> |> dark_matter()
      import Kojin
      ~s[
        impl ThirdPartyTrait for i32 {
        }
      ]
      |> dark_matter()

  """
  def trait_impl(trait, type, doc \\ nil)

  def trait_impl(trait, type, doc) when is_atom(type) or is_binary(type) do
    trait_impl(trait, Type.type(type), doc)
  end

  @spec trait_impl(Kojin.Rust.Trait.t(), Kojin.Rust.Type.t()) :: Kojin.Rust.TraitImpl.t()
  def trait_impl(%Trait{} = trait, %Type{} = type, doc) do
    %TraitImpl{
      type: type,
      trait: trait,
      doc: doc
    }
  end

  def trait_impl(trait, type, doc) when is_binary(trait),
    do: trait_impl(Trait.trait(trait, "", []), type, doc)

  defimpl String.Chars do
    def to_string(%TraitImpl{} = trait_impl) do
      import Kojin.Utils
      trait = trait_impl.trait
      type = trait_impl.type

      [
        if(trait_impl.doc, do: triple_slash_comment(trait_impl.doc)),
        "impl #{trait.name} for #{type} {",
        indent_block(join_content(trait.functions)),
        "}"
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n")
    end
  end
end
