defmodule Kojin.Rust.Trait do
  @moduledoc """
  Rust _trait_ definition.
  """

  alias Kojin.Rust.{Fn, Trait, ToCode, Generic, Use}
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
    field(:generic, Generic.t())
    field(:visibility, atom, default: :private)
    field(:associated_types, list(), default: [])
    field(:super_traits, list(Trait | binary | atom), default: [])
    field(:path, binary, default: nil)
    field(:uses, list(Use.t()), default: [])
  end

  @spec trait(atom | binary, nil | binary, list(), keyword) :: Kojin.Rust.Trait.t()
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

  def _trait(id, name, doc, functions, opts) do
    defaults = [
      generic: nil,
      visibility: :private,
      associated_types: [],
      super_traits: [],
      path: nil,
      uses: []
    ]

    opts = Kojin.check_args(defaults, opts)

    %Trait{
      name: name,
      id: id,
      doc: doc || "TODO: Document trait #{name}",
      functions: Enum.map(functions, fn fun -> Kojin.Rust.Fn.fun(fun) end),
      generic:
        if(opts[:generic] != nil) do
          Generic.generic(opts[:generic])
        else
          nil
        end,
      associated_types:
        Enum.map(
          opts[:associated_types],
          fn at ->
            Kojin.Rust.AssociatedType.associated_type(at)
          end
        ),
      super_traits: opts[:super_traits],
      visibility: opts[:visibility],
      path: opts[:path],
      uses: opts[:uses]
    }
  end

  def pub_trait(name, doc \\ nil, functions \\ [], opts \\ []) do
    trait(name, doc, functions, Keyword.merge(opts, visibility: :pub))
  end

  def trait_name(trait),
    do:
      trait.name
      |> cap_camel

  def super_trait(t) when is_binary(t), do: t
  def super_trait(%Trait{} = t), do: t.name
  def super_trait(t) when is_atom(t), do: cap_camel(t)

  @spec code(Trait.t()) :: binary
  def code(%Trait{} = trait) do
    visibility = Kojin.Rust.visibility_decl(trait.visibility)

    {generic, bounds_decl} =
      if(trait.generic) do
        {Generic.code(trait.generic), Generic.bounds_decl(trait.generic)}
      else
        {"", ""}
      end

    super_traits =
      if(!Enum.empty?(trait.super_traits)) do
        ": " <>
          (trait.super_traits
           |> Enum.map(fn st -> super_trait(st) end)
           |> Enum.join(" + "))
      else
        ""
      end

    [
      triple_slash_comment(trait.doc),
      "#{visibility}trait #{trait_name(trait)}#{generic} #{super_traits}#{bounds_decl} {",
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
    def to_code(%Trait{} = trait) do
      "#{trait}"
    end
  end
end
