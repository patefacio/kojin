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
  alias Kojin.Rust.{Trait, TraitImpl, Type, Generic, Utils}
  import Kojin.{Id, Utils}
  import Kojin.Rust.Utils
  require Logger

  typedstruct enforce: true do
    field(:type, Type.t())
    field(:trait, Trait.t())
    field(:doc, String.t())
    field(:generic, Generic.t())
    field(:bodies, map())
    field(:unit_tests, list(atom))
    field(:generic_args, list())
    field(:associated_types, map())
    field(:test_module_name, String.t())
  end

  @doc """
  Create a `Kojin.Rust.TraitImpl` from the given `trait`
  and its implementation specific doc comment, `doc`.

  ## Examples

      iex> import Kojin.Rust.{TraitImpl}
      ...> import Kojin
      ...> trait_impl("ThirdPartyTrait", :i32)
      ...> |> String.Chars.to_string()
      ...> |> dark_matter()
      import Kojin
      ~s[
        ///  Implementation of ThirdPartyTrait for i32
        impl ThirdPartyTrait for i32 {
        }
      ]
      |> dark_matter()

  """
  def trait_impl(trait, type, opts \\ [])

  def trait_impl(trait, type, opts) when is_atom(type) or is_binary(type) do
    trait_impl(trait, Type.type(type), opts)
  end

  @spec trait_impl(Trait.t(), Type.t(), list()) :: TraitImpl.t()
  def trait_impl(%Trait{} = trait, %Type{} = type, opts) do
    defaults = [
      generic: nil,
      doc: "Implementation of #{trait.name} for #{type}",
      bodies: %{},
      unit_tests: [],
      generic_args: [],
      associated_types: %{},
      test_module_name: make_module_name("trait_impl_test_#{Kojin.Id.snake(trait.name)}")
    ]

    opts = Kojin.check_args(defaults, opts)

    %TraitImpl{
      type: type,
      trait: trait,
      doc: opts[:doc],
      generic:
        if(opts[:generic] != nil) do
          Generic.generic(opts[:generic])
        else
          trait.generic
        end,
      generic_args: opts[:generic_args],
      bodies: opts[:bodies],
      unit_tests: opts[:unit_tests],
      associated_types: opts[:associated_types],
      test_module_name: opts[:test_module_name]
    }
  end

  @spec trait_impl(binary(), Type.t(), list()) :: TraitImpl.t()
  def trait_impl(trait, type, opts) when is_binary(trait),
    do: trait_impl(Trait.trait(trait, "", []), type, opts)

  @spec trait_impl(Trait.t(), binary | atom(), list()) :: TraitImpl.t()
  def trait_impl(%Trait{} = trait, type, opts) when is_binary(type) or is_atom(type),
    do: trait_impl(trait, Type.type(type), opts)

  defimpl String.Chars do
    def to_string(%TraitImpl{} = trait_impl) do
      import Kojin.Utils

      trait = trait_impl.trait

      functions =
        trait.functions
        |> Enum.filter(fn f -> !f.body end)
        |> Enum.map(fn f ->
          body = Map.get(trait_impl.bodies, f.name)

          if(!body) do
            Logger.warn("Body of `#{f.name}` not present in trait #{trait.name}")
          end

          %{f | body: body}
        end)

      type = trait_impl.type

      {generic, bounds_decl} =
        if(trait_impl.generic) do
          {Generic.code(trait_impl.generic), Generic.bounds_decl(trait_impl.generic)}
        else
          {"", ""}
        end

      Logger.debug(
        "#{trait.name} ->  generic(#{generic}) #{bounds_decl} for #{type} with bounds #{bounds_decl}"
      )

      generic_args =
        trait_impl.generic_args
        |> Enum.map(fn generic_arg ->
          case generic_arg do
            :a -> "'a"
            :b -> "'b"
            :c -> "'c"
            :d -> "'d"
            :static -> "'static"
            _ -> "#{generic_arg}"
          end
        end)
        |> Enum.join(", ")

      generic_args =
        if("" == generic_args) do
          ""
        else
          "<#{generic_args}>"
        end

      [
        if(trait_impl.doc, do: triple_slash_comment(trait_impl.doc)),
        "impl#{generic} #{trait.name}#{generic_args} for #{type}#{bounds_decl} {",
        if(!Enum.empty?(trait_impl.associated_types)) do
          Utils.announce_section(
            "type aliases",
            Map.keys(trait_impl.associated_types)
            |> Enum.sort()
            |> Enum.map(fn t ->
              associated_type =
                trait_impl.trait.associated_types
                |> Enum.find(fn at -> at.id == "#{t}" end)

              [
                triple_slash_comment(associated_type.doc),
                "type #{cap_camel(t)} = #{Map.get(trait_impl.associated_types, t)};"
              ]
              |> Enum.join("\n")
            end)
            |> Enum.join("\n")
          )
        end,
        indent_block(join_content(functions)),
        "}"
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n")
    end
  end
end
