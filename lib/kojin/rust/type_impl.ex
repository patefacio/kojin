defmodule Kojin.Rust.TypeImpl do
  use TypedStruct
  import Kojin.{Id, Utils, CodeBlock, Rust.Utils}

  alias Kojin.Rust.{Type, ToCode, TypeImpl, Fn}

  typedstruct do
    field(:type, Type.t(), enforce: true)
    field(:functions, list(Fn.t()), default: [])
    field(:code_block, Kojin.CodeBlock.t())
    field(:doc, String.t() | nil, default: nil)
    field(:type_name, String.t())
    field(:unit_tests, list(atom))
  end

  def type_impl(%TypeImpl{} = t), do: t
  def type_impl([type, functions, opts]), do: type_impl(type, functions, opts)
  def type_impl([type, functions]), do: type_impl(type, functions, [])
  def type_impl([type]), do: type_impl(type, [], [])

  def type_impl(type, functions \\ [], opts \\ []) do
    type = Type.type(type)
    type_name = type.base |> cap_camel
    code_block_prefix = "#{type_name}"
    code_block = code_block("impl #{type}")

    defaults = [doc: "Implementation for #{type}", unit_tests: []]
    opts = Kojin.check_args(defaults, opts)

    %TypeImpl{
      type: type,
      type_name: type_name,
      functions:
        functions
        |> Enum.map(fn f ->
          Fn.fun_with_tag_prefix(f, join_content([code_block_prefix, f.tag_prefix], "::"))
        end),
      code_block: code_block,
      doc: opts[:doc],
      unit_tests: opts[:unit_tests]
    }
  end

  @doc ~s"""
  Returns the code for the TypeImpl.

  ## Examples

      iex> import Kojin.Rust.{Fn, TypeImpl}
      ...> Kojin.Rust.TypeImpl.code(type_impl(:my_struct, [ fun(:f, "Function does f")]))
      ...> |> String.replace(~r/\\s+/, "")
      ~s'''
      ///  Implementation for MyStruct
      impl MyStruct {
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
      ''' 
      |> String.replace(~r/\\s+/, "")
  """
  def code(impl) do
    tname = impl.type.base |> cap_camel

    functions =
      impl.functions
      |> Enum.sort()

    [
      join_content([
        String.trim(triple_slash_comment(impl.doc)),
        "impl #{tname} {"
      ]),
      join_content(
        [
          String.trim_trailing(text(impl.code_block)),
          announce_section(
            "pub functions",
            functions |> Enum.filter(fn f -> f.visibility == :pub end)
          ),
          announce_section(
            "pub(crate) functions",
            functions |> Enum.filter(fn f -> f.visibility == :pub_crate end)
          ),
          announce_section(
            "private functions",
            functions |> Enum.filter(fn f -> f.visibility == :private end)
          ),
          announce_section(
            "pub(self) functions",
            functions |> Enum.filter(fn f -> f.visibility == :pub_self end)
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
