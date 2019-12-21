defmodule Kojin.Rust.Trait do
  @moduledoc """
  Rust _trait_ definition.
  """

  alias Kojin.Rust.{Fn, Trait, ToCode}
  import Kojin.{Id, Utils, Rust.Utils}
  use TypedStruct

  @typedoc """
  A rust _trait_.
  """
  typedstruct enforce: true do
    field(:name, String)
    field(:id, atom)
    field(:doc, String.t())
    field(:functions, list(Fn.t()), default: [])
    field(:visibility, atom, default: :private)
    field(:associated_types, list(), default: [])
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
      ...> (%Kojin.Rust.Trait{ name: "ThirdPartyTrait<T>"} = trait("ThirdPartyTrait<T>")) && :good
      :good


      iex> import Kojin.Rust.Trait
      ...> import Kojin
      ...> trait(:trait_with_assoc_type, "A trait with an associated type", [],
      ...>     associated_types: [[:t, "Assoc Type"]])
      ...> |> String.Chars.to_string()
      ...> |> dark_matter()
      import Kojin
      ~S[
      ///  A trait with an associated type
      trait TraitWithAssocType {
          ////////////////////////////////////////////////////////////////////////////////////
          // --- associated types ---
          ////////////////////////////////////////////////////////////////////////////////////
          /// Assoc Type
          type T;
      }
      ]
      |> Kojin.dark_matter()

      iex> import Kojin.Rust.Trait
      ...> (%Kojin.Rust.Trait{ name: "ThirdPartyTrait<T>"} = trait("ThirdPartyTrait<T>")) && :good
      :good

  """

  def trait(name, doc \\ nil, functions \\ [], opts \\ [])

  def trait(name, doc, functions, opts) when is_binary(name),
    do: _trait(nil, name, doc, functions, opts)

  def trait(name, doc, functions, opts) when is_atom(name),
    do: _trait(name, cap_camel(name), doc, functions, opts)

  defp _trait(id, name, doc, functions, opts) do
    defaults = [visibility: :private, associated_types: []]
    opts = Kojin.check_args(defaults, opts)

    %Trait{
      name: name,
      id: id,
      doc: doc || "TODO: Document trait #{name}",
      functions: Enum.map(functions, fn fun -> Kojin.Rust.Fn.fun(fun) end),
      associated_types:
        Enum.map(opts[:associated_types], fn at ->
          Kojin.Rust.AssociatedType.associated_type(at)
        end),
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
      announce_section("associated types", trait.associated_types),
      trait.functions
      |> Enum.map(fn fun ->
        if(fun.body) do
          "#{fun}"
        else
          "#{Fn.commented_signature(fun)};"
        end
      end)
      |> Enum.join("\n\n")
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
