defmodule Kojin.Rust.Module do
  @moduledoc """
  Rust _module_ definition.
  """

  alias Kojin.Rust.{
    TraitImpl,
    TypeImpl,
    Struct,
    Trait,
    Module,
    Uses,
    Fn,
    GenerateSpec,
    GeneratedRustModule
  }

  import Kojin
  import Kojin.{Id, Utils, Rust, Rust.Utils}
  use TypedStruct
  use Vex.Struct
  require Logger

  @typedoc """
  A rust _module_.
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:type_name, String.t(), enforce: true)
    field(:visibility, atom, default: :private)
    field(:doc, String.t())
    field(:type, atom, default: :file)
    field(:traits, list(Trait.t()), default: [])
    field(:functions, list(Fn.t()), default: [])
    field(:structs, list(Struct.t()), default: [])
    field(:impls, list(TypeImpl.t() | TraitImpl.t()), default: [])
    field(:modules, list(Module.t()), default: [])
    field(:file_name, String.t())
    field(:uses, Uses.t(), default: nil)
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
          modules: [],
          visibility: :private,
          uses: []
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
      file_name: "#{name}.rs",
      visibility: opts[:visibility],
      uses: Uses.uses(opts[:uses])
    }
  end

  def mod_decls(module) do
    module.modules
    |> Enum.filter(fn module -> module.type != :inline end)
    |> Enum.map(fn module ->
      visibility = visibility_decl(module.visibility)
      "#{visibility}mod #{snake(module.name)};"
    end)
  end

  def content(module) do
    join_content(
      [
        ## Include comments
        Kojin.Rust.doc_comment(module.doc),

        ## Uses
        module.uses,
        announce_section("mod decls", Module.mod_decls(module)),
        announce_section("functions", module.functions),
        announce_section("traits", module.traits),
        announce_section("structs", module.structs),

        ## Include Nested Modules
        module.modules
        |> Enum.filter(fn module -> module.type == :inline end)
        |> Enum.map(fn module ->
          visibility = visibility_decl(module.visibility)

          join_content([
            "#{visibility}mod #{snake(module.name)} {",
            indent_block(content(module)) |> String.trim_trailing(),
            "}"
          ])
        end)
      ],
      "\n\n"
    )
  end

  def inline_children(module) do
    module.modules
    |> Enum.reduce(%{}, fn module, acc ->
      Map.put(acc, module.name, {module.type, inline_children(module)})
    end)
  end

  @spec generate(Module.t(), GenerateSpec.t()) :: any
  def generate(module, generate_spec) do
    Logger.debug("Generating module `#{module.name}`")

    child_path =
      if module.name == :lib do
        generate_spec.path
      else
        Path.join([generate_spec.path, "#{module.name}"])
      end

    my_path =
      case module.type do
        :file -> Path.join([generate_spec.path, module.file_name])
        :directory -> Path.join([generate_spec.path, "#{module.name}", "mod.rs"])
        :inline -> nil
      end

    content =
      if module.type != :inline do
        %{
          my_path => GeneratedRustModule.generated_rust_module(my_path, content(module))
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
