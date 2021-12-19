defmodule Kojin.Rust.Module do
  @moduledoc """
  Rust _module_ definition.
  """

  alias Kojin.Rust.{
    Attr,
    Const,
    Fn,
    Module,
    SimpleEnum,
    Struct,
    Trait,
    TraitImpl,
    TypeAlias,
    TypeImpl,
    Uses
  }

  import Kojin
  import Kojin.{CodeBlock, Id, Utils, Rust, Rust.Utils, Rust.Fn}
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
    field(:consts, list(Const.t()), default: [])
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
    field(:macro_uses, list(binary | atom), default: [])
    field(:test_macro_uses, list(binary | atom), default: [])
    field(:attrs, list(Attr.t()))
  end

  def module(name, doc, opts \\ []) when is_binary(doc) do
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
      consts: [],
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
      test_macro_uses: [],
      code_block: code_block("mod-def #{snake(name)}"),
      attrs: []
    ]

    opts = Kojin.check_args(defaults, opts)

    %Module{
      name: name,
      type_name: cap_camel(name),
      doc: doc,
      type: opts[:type],
      consts: opts[:consts],
      enums: opts[:enums],
      traits: opts[:traits],
      functions: opts[:functions],
      structs: opts[:structs],
      impls: impls(opts[:impls]),
      modules: submodules,
      file_name: "#{name}.rs",
      visibility: opts[:visibility],
      uses: Uses.uses(opts[:uses]),
      type_aliases:
        Enum.map(opts[:type_aliases], fn type_alias -> TypeAlias.type_alias(type_alias) end),
      has_non_inline_submodules: has_non_inline_submodules,
      macro_uses: opts[:macro_uses],
      test_macro_uses: opts[:test_macro_uses],
      code_block: opts[:code_block],
      attrs: opts[:attrs]
    }
  end

  def pub_module(name, doc, opts \\ []) when is_binary(doc),
    do: module(name, doc, Keyword.merge(opts, visibility: :pub))

  def ensure_is_impl(%TypeImpl{} = type_impl), do: type_impl
  def ensure_is_impl(%TraitImpl{} = trait_impl), do: trait_impl
  def impls(impls) when is_list(impls), do: Enum.map(impls, fn impl -> ensure_is_impl(impl) end)

  def all_modules(%Module{} = module) do
    Enum.reduce(
      module.modules,
      [],
      fn module, acc ->
        [module | acc]
      end
    )
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
    functions_with_unit_tests =
      [
        module.functions
        |> Enum.filter(fn m -> m.include_unit_test end)
        |> Enum.map(fn f -> {"test_#{module.name}", f.name} end),
        module.impls
        |> Enum.map(fn impl ->
          Enum.map(
            impl.unit_tests,
            fn unit_test_name ->
              {impl.test_module_name, unit_test_name}
            end
          )
        end)
      ]
      |> List.flatten()
      |> Enum.group_by(fn {module_name, _function_name} -> module_name end)

    submodules =
      if(Enum.empty?(functions_with_unit_tests)) do
        module.modules
      else
        [
          module(
            :unit_tests,
            "Unit tests for #{module.name}",
            attrs: [Attr.attr("cfg(test)")],
            type: :inline,
            modules:
              functions_with_unit_tests
              |> Enum.filter(fn {module_name, _functions} -> module_name != nil end)
              |> Enum.map(fn {module_name, functions} ->
                module(
                  module_name,
                  "Tests",
                  functions:
                    Enum.map(
                      functions,
                      fn {_, function} ->
                        fun(
                          "test_#{function}",
                          "Unit test for `#{function}`",
                          [],
                          is_test: true
                        )
                      end
                    ),
                  type: :inline
                )
              end)

            #            functions:
            #              functions_with_unit_tests
            #              |> Enum.filter(fn {module_name, functions} -> module_name == nil end)
            #              |> Enum.map(fn {module_name, functions} -> functions end)
            #              |> Enum.map(
            #                   fn [nil, test_function] ->
            #                   IO.puts "MN TF -> #{inspect test_function}"
            #                     fun(
            #                       "test_#{test_function}",
            #                       "Unit test for `#{test_function}`",
            #                       [],
            #                       is_test: true
            #                     )
            #                   end
            #                 )
          )
          | module.modules
        ]
      end

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
        announce_section(
          "test-macro-use imports",
          join_content(
            Enum.map(
              module.test_macro_uses,
              fn mu ->
                "#[cfg(test)]\n#[macro_use]\nextern crate #{mu};"
              end
            )
          )
        ),
        announce_section("module uses", join_content(module.uses)),
        announce_section("mod decls", join_content(Module.mod_decls(module))),
        announce_section("type aliases", module.type_aliases, "\n"),
        announce_section("constants", module.consts),
        announce_section("enums", module.enums),
        announce_section(
          "functions",
          module.functions
          |> Enum.filter(fn f -> !f.is_test end)
        ),
        announce_section("traits", module.traits),
        announce_section("structs", module.structs),
        announce_section("impls", module.impls),
        announce_section(
          "cfg(test) functions",
          module.functions
          |> Enum.filter(fn f -> f.is_test end)
        ),

        ## Include Nested Modules
        submodules
        |> Enum.filter(fn module -> module.type == :inline end)
        |> Enum.map(fn module ->
          visibility = visibility_decl(module.visibility)

          join_content([
            module.attrs
            |> Enum.map(fn attr -> Attr.external(attr) end),
            "#{visibility}mod #{snake(module.name)} {",
            indent_block(content(module))
            |> String.trim_trailing(),
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
    |> Enum.reduce(
      %{},
      fn module, acc ->
        Map.put(acc, module.name, {module.type, inline_children(module)})
      end
    )
  end
end
