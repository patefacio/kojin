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
  alias Kojin.Rust.{Trait, TraitImpl, Type, Generic}
  import Kojin.Utils

  typedstruct enforce: true do
    field(:type, Type.t())
    field(:trait, Trait.t())
    field(:doc, String.t())
    field(:generic, Generic.t())
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
  def trait_impl(trait, type, doc \\ nil, opts \\ [])

  def trait_impl(trait, type, doc, opts) when is_atom(type) or is_binary(type) do
    trait_impl(trait, Type.type(type), doc, opts)
  end

  @spec trait_impl(Kojin.Rust.Trait.t(), Kojin.Rust.Type.t()) :: Kojin.Rust.TraitImpl.t()
  def trait_impl(%Trait{} = trait, %Type{} = type, doc, opts) do
    defaults = [generic: nil]
    opts = Kojin.check_args(defaults, opts)

    %TraitImpl{
      type: type,
      trait: trait,
      doc: doc,
      generic:
        if(opts[:generic] != nil) do
          Generic.generic(opts[:generic])
        else
          nil
        end
    }
  end

  def trait_impl(trait, type, doc, opts) when is_binary(trait),
    do: trait_impl(Trait.trait(trait, "", []), type, doc, opts)

  defimpl String.Chars do
    def to_string(%TraitImpl{} = trait_impl) do
      import Kojin.Utils
      trait = trait_impl.trait
      type = trait_impl.type

      {generic, bounds_decl} =
        if(trait_impl.generic) do
          {Generic.code(trait_impl.generic), Generic.bounds_decl(trait_impl.generic)}
        else
          {"", ""}
        end

      [
        if(trait_impl.doc, do: triple_slash_comment(trait_impl.doc)),
        "impl#{generic} #{trait.name} for #{type}#{bounds_decl} {",
        indent_block(join_content(trait.functions)),
        "}"
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n")
    end
  end
end
