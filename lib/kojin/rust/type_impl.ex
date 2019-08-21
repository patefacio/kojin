defmodule Kojin.Rust.TypeImpl do
  use TypedStruct
  import Kojin
  import Kojin.{Id, Utils, CodeBlock}

  alias Kojin.Rust.{Type, ToCode, TypeImpl, Fn}

  typedstruct do
    field(:type, Type.t(), enforce: true)
    field(:functions, list(Fn.t()), default: [])
    field(:code_block, Kojin.CodeBlock.t())
    field(:doc, String.t() | nil, default: nil)
  end

  def type_impl(%TypeImpl{} = t), do: t
  def type_impl([type, functions, opts]), do: type_impl(type, functions, opts)

  def type_impl(type, functions \\ [], opts \\ []) do
    type = Type.type(type)
    code_block = code_block("impl #{type}")

    opts = Keyword.merge(opts, doc: "Implementation for #{type}")

    %TypeImpl{
      type: type,
      functions: functions |> Enum.map(fn f -> Fn.fun(f) end),
      code_block: code_block,
      doc: opts[:doc]
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
        
        fn f() {
          // α <MyStruct::fn f>
          // ω <MyStruct::fn f>
        }
        
      }
      ''' 
      |> String.replace(~r/\\s+/, "")
  """
  def code(impl) do
    tname = impl.type.base |> cap_camel

    functions =
      impl.functions
      |> Enum.map(fn f -> Fn.code(f, "#{tname}::") end)
      |> Enum.join("\n")
      |> String.trim_trailing()

    [
      join_content([
        String.trim(triple_slash_comment(impl.doc)),
        "impl #{tname} {"
      ]),
      join_content(
        [
          String.trim_trailing(text(impl.code_block)),
          functions
        ],
        "\n\n"
      )
      |> indent_block,
      "}"
    ]
    |> join_content("\n")
  end

  defimpl(String.Chars, do: def(to_string(impl), do: "#{TypeImpl.code(impl)}"))
  defimpl(ToCode, do: def(to_code(impl), do: "#{impl}"))
end
