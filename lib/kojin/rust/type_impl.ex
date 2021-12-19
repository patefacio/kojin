defmodule Kojin.Rust.TypeImpl do
  use TypedStruct
  import Kojin.{Id, Utils, CodeBlock, Rust.Utils}

  alias Kojin.Rust.{Type, ToCode, TypeImpl, Fn, Generic}

  typedstruct do
    field(:type, Type.t(), enforce: true)
    field(:functions, list(Fn.t()), default: [])
    field(:generic, Generic.t())
    field(:generic_args, list())
    field(:code_block, Kojin.CodeBlock.t())
    field(:doc, String.t() | nil, default: nil)
    field(:type_name, String.t())
    field(:unit_tests, list(atom))
    field(:test_module_name, String.t())
  end

  def type_impl(%TypeImpl{} = t), do: t
  def type_impl([type, functions, opts]), do: type_impl(type, functions, opts)
  def type_impl([type, functions]), do: type_impl(type, functions, [])
  def type_impl([type]), do: type_impl(type, [], [])

  def type_impl(type, functions \\ [], opts \\ []) do
    type = Type.type(type)

    type_name =
      type.base
      |> cap_camel

    code_block_prefix = "#{type_name}"
    code_block = code_block("impl #{type}")

    defaults = [
      doc: "Implementation for #{type}",
      generic: nil,
      generic_args: nil,
      unit_tests: [],
      test_module_name: make_module_name("type_impl_test_#{type_name}")
    ]

    opts = Kojin.check_args(defaults, opts)

    generic_args =
      if opts[:generic_args] != nil, do: Generic.generic(opts[:generic_args]), else: nil

    generic = if opts[:generic] != nil, do: Generic.generic(opts[:generic]), else: generic_args

    %TypeImpl{
      type: type,
      type_name: type_name,
      generic: generic,
      generic_args: generic_args,
      functions:
        functions
        |> Enum.map(fn f ->
          Fn.fun_with_tag_prefix(f, join_content([code_block_prefix, f.tag_prefix], "::"))
        end),
      code_block: code_block,
      doc: opts[:doc],
      unit_tests: opts[:unit_tests],
      test_module_name: opts[:test_module_name]
    }
  end

  @doc ~s"""
  Returns the code for the TypeImpl.

  ## Examples

      iex> import Kojin.Rust.{Fn, TypeImpl}
      ...> import Kojin
      ...> Kojin.Rust.TypeImpl.code(type_impl(:my_struct, [ fun(:f, "Function does f") ],
      ...>  generic: [ lifetimes: [:b]], generic_args: [ type_parms: ["X", :Y ]]))
      ...> |> dark_matter()
      import Kojin
      ~s[
        ///Implementation for MyStruct
        impl<'b> MyStruct<X, Y> {
          // α <impl MyStruct>
          // ω <impl MyStruct>
          ////////////////////////////////////////////////////////////////////////////////////
          //--- private functions ---
          ////////////////////////////////////////////////////////////////////////////////////
          /// Function does f
          fn f() {
            // α <MyStruct(fn f)>
            // ω <MyStruct(fn f)>
          }
        }
      ]
      |> dark_matter

  """
  def code(impl = %TypeImpl{}) do
    {generic, bounds_decl} =
      if(impl.generic) do
        {Generic.code(impl.generic), Generic.bounds_decl(impl.generic)}
      else
        {"", ""}
      end

    generic_args = if impl.generic_args, do: "#{impl.generic_args}", else: ""

    tname =
      impl.type.base
      |> cap_camel

    functions =
      impl.functions
      |> Enum.sort(fn a, b -> {a.visibility, a.name} <= {b.visibility, b.name} end)

    [
      join_content([
        String.trim(triple_slash_comment(impl.doc)),
        "impl#{generic} #{tname}#{generic_args}#{bounds_decl} {"
      ]),
      join_content(
        [
          String.trim_trailing(text(impl.code_block)),
          announce_section(
            "pub functions",
            functions
            |> Enum.filter(fn f -> f.visibility == :pub end)
          ),
          announce_section(
            "pub(crate) functions",
            functions
            |> Enum.filter(fn f -> f.visibility == :pub_crate end)
          ),
          announce_section(
            "private functions",
            functions
            |> Enum.filter(fn f -> f.visibility == :private end)
          ),
          announce_section(
            "pub(self) functions",
            functions
            |> Enum.filter(fn f -> f.visibility == :pub_self end)
          )
        ],
        "\n\n"
      )
      |> indent_block,
      "}"
    ]
    |> join_content("\n")
  end

  defimpl(String.Chars, do: def(to_string(impl), do: "#{TypeImpl.code(impl)}"))

  defimpl ToCode do
    @spec to_code(TypeImpl.t()) :: binary
    def to_code(impl), do: "#{impl}"
  end
end
