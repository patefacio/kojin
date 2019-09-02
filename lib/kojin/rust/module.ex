defmodule Kojin.Rust.Module do
  @moduledoc """
  Rust _module_ definition.
  """

  alias Kojin.Rust.{TraitImpl, TypeImpl, Struct, Trait, Module, Fn}
  import Kojin
  import Kojin.{Id, Utils}
  use TypedStruct
  use Vex.Struct
  require Logger

  @typedoc """
  A rust _module_.
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:type_name, enforce: true)
    field(:doc, String.t())
    field(:type, atom, default: :file)
    field(:traits, list(Trait.t()), default: [])
    field(:functions, list(Fn.t()), default: [])
    field(:structs, list(Struct.t()), default: [])
    field(:impls, list(TypeImpl.t() | TraitImpl.t()), default: [])
    field(:modules, list(Module.t()), default: [])
    field(:file_name, String.t())
  end

  def module(name, doc, opts \\ []) do
    require_snake(name)

    opts =
      Keyword.merge(
        [
          type: :file,
          traits: [],
          functions: [],
          structs: [],
          impls: [],
          modules: []
        ],
        opts
      )

    %Module{
      name: name,
      type_name: cap_camel(name),
      doc: doc,
      type: opts[:type],
      traits: opts[:traits],
      functions: opts[:functions],
      structs: opts[:structs],
      impls: opts[:impls],
      modules: opts[:modules],
      file_name: "#{name}.rs"
    }
  end

  def content(module) do
    join_content([
      triple_slash_comment(module.doc),
      module.functions
      |> Enum.map(fn fun -> "#{fun}" end),
      module.modules
      |> Enum.filter(fn module -> module.type == :inline end)
      |> Enum.map(fn module ->
        join_content([
          "module #{module.type_name} {",
          indent_block(content(module)),
          "}"
        ])
      end)
    ])
  end

  def inline_children(module) do
    module.modules
    |> Enum.reduce(%{}, fn module, acc ->
      Map.put(acc, module.name, {module.type, inline_children(module)})
    end)
  end

  @spec generate(Module.t(), GenerateSpec.t()) :: any
  def generate(module, generate_spec) do
    Logger.debug("Generating module `#{module.name}` with spec #{inspect(generate_spec)}")

    child_path = Path.join([generate_spec.path, "#{module.name}"])

    my_path =
      case module.type do
        :file -> Path.join([generate_spec.path, module.file_name])
        :directory -> Path.join([generate_spec.path, "#{module.name}", "mod.rs"])
        :inline -> nil
      end

    content =
      if module.type != :inline do
        %{
          my_path => %{
            path: my_path,
            content: content(module)
          }
        }
      else
        %{}
      end

    module.modules
    |> Enum.reduce(content, fn child_module, acc ->
      generate_spec =
        if child_module.type != :inline do
          %{
            generate_spec
            | path: child_path,
              parent: module
          }
        else
          generate_spec
        end

      Map.merge(
        acc,
        generate(child_module, generate_spec)
      )
    end)
  end
end
