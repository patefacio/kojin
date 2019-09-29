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
    Fn
  }

  import Kojin
  import Kojin.{Id, Utils, Rust, Rust.Utils}
  use TypedStruct
  use Vex.Struct
  require Logger

  @typedoc """
  A rust _module_.
  """
  typedstruct enforce: true do
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
    field(:has_non_inline_submodules, boolean)
  end

  def module(name, doc, opts \\ []) do
    require_snake(name)

    submodules = Keyword.get(opts, :modules, [])

    has_non_inline_submodules =
      submodules
      |> Enum.any?(fn module -> module.has_non_inline_submodules || module.type != :inline end)

    default_type =
      if has_non_inline_submodules do
        :directory
      else
        :file
      end

    defaults = [
      type: default_type,
      traits: [],
      functions: [],
      structs: [],
      impls: [],
      visibility: :private,
      modules: submodules,
      uses: []
    ]

    opts = Kojin.check_args(defaults, opts)

    %Module{
      name: name,
      type_name: cap_camel(name),
      doc: doc,
      type: opts[:type],
      traits: opts[:traits],
      functions: opts[:functions],
      structs: opts[:structs],
      impls: opts[:impls],
      modules: submodules,
      file_name: "#{name}.rs",
      visibility: opts[:visibility],
      uses: Uses.uses(opts[:uses]),
      has_non_inline_submodules: has_non_inline_submodules
    }
  end

  def all_modules(%Module{} = module) do
    Enum.reduce(module.modules, [], fn module, acc ->
      [module | acc]
    end)
    |> List.flatten()
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
        announce_section("functions", module.functions |> Enum.filter(fn f -> !f.is_test end)),
        announce_section("traits", module.traits),
        announce_section("structs", module.structs),
        announce_section("impls", module.impls),
        announce_section(
          "cfg(test) functions",
          module.functions |> Enum.filter(fn f -> f.is_test end)
        ),

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
end
