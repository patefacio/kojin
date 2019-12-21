defmodule Kojin.Rust.Module do
  @moduledoc """
  Rust _module_ definition.
  """

  alias Kojin.Rust.{
    TraitImpl,
    TypeImpl,
    SimpleEnum,
    Struct,
    Trait,
    Module,
    Uses,
    Fn
  }

  import Kojin
  import Kojin.{CodeBlock, Id, Utils, Rust, Rust.Utils}
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
    field(:enums, list(SimpleEnum.t()), default: [])
    field(:traits, list(Trait.t()), default: [])
    field(:functions, list(Fn.t()), default: [])
    field(:structs, list(Struct.t()), default: [])
    field(:impls, list(TypeImpl.t() | TraitImpl.t()), default: [])
    field(:modules, list(Module.t()), default: [])
    field(:file_name, String.t())
    field(:uses, Uses.t(), default: nil)
    field(:type_aliases, list(TypeAlias.t()), default: [])
    field(:has_non_inline_submodules, boolean)
    field(:code_block, Kojin.CodeBlock.t(), default: nil)
    field(:macro_uses, list(binary), default: [])
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
      enums: [],
      traits: [],
      functions: [],
      structs: [],
      impls: [],
      visibility: :private,
      modules: submodules,
      uses: [],
      type_aliases: [],
      macro_uses: [],
      code_block: code_block("mod-def #{snake(name)}")
    ]

    opts = Kojin.check_args(defaults, opts)

    %Module{
      name: name,
      type_name: cap_camel(name),
      doc: doc,
      type: opts[:type],
      enums: opts[:enums],
      traits: opts[:traits],
      functions: opts[:functions],
      structs: opts[:structs],
      impls: opts[:impls],
      modules: submodules,
      file_name: "#{name}.rs",
      visibility: opts[:visibility],
      uses: Uses.uses(opts[:uses]),
      type_aliases: opts[:type_aliases],
      has_non_inline_submodules: has_non_inline_submodules,
      macro_uses: opts[:macro_uses],
      code_block: opts[:code_block]
    }
  end

  def all_modules(%Module{} = module) do
    Enum.reduce(module.modules, [], fn module, acc ->
      [module | acc]
    end)
    |> List.flatten()
  end

  def mod_decls(%Module{} = module) do
    module.modules
    |> Enum.filter(fn module -> module.type != :inline end)
    |> Enum.map(fn module ->
      visibility = visibility_decl(module.visibility)
      "#{visibility}mod #{snake(module.name)};"
    end)
  end

  def content(%Module{} = module) do
    join_content(
      [
        ## Include comments
        Kojin.Rust.doc_comment(module.doc),
        announce_section(
          "macro-use imports",
          join_content(
            Enum.map(module.macro_uses, fn mu -> "#[macro_use]\nextern crate #{mu};" end)
          )
        ),
        announce_section("module uses", join_content(module.uses)),
        announce_section("mod decls", join_content(Module.mod_decls(module))),
        announce_section("type aliases", module.type_aliases, "\n"),
        announce_section("enums", module.enums),
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
        end),
        text(module.code_block)
      ],
      "\n\n"
    )
  end

  def inline_children(%Module{} = module) do
    module.modules
    |> Enum.reduce(%{}, fn module, acc ->
      Map.put(acc, module.name, {module.type, inline_children(module)})
    end)
  end
end
