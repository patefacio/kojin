defmodule Kojin.Rust.TypeImpl do
  use TypedStruct
  import Kojin
  import Kojin.{Id, Utils}

  alias Kojin.Rust.{Type, ToCode, TypeImpl, Fn}

  typedstruct do
    field(:type, Type.t(), enforce: true)
    field(:functions, list(Fn.t()), default: [])
  end

  def type_impl(type, functions \\ []) do
    %TypeImpl{
      type: Type.type(type),
      functions: functions |> Enum.map(fn f -> Fn.fun(f) end)
    }
  end

  def code(impl) do
    tname = impl.type.base |> cap_camel
    impl_block = c_block("impl #{tname}") |> indent_block |> String.trim_trailing()

    functions =
      impl.functions
      |> Enum.map(fn f -> Fn.code(f, "#{tname}::") end)
      |> Enum.join("\n")
      |> indent_block
      |> String.trim_trailing()

    [
      "impl #{tname} {",
      impl_block,
      functions,
      "}"
    ]
    |> join_content("\n\n")
  end

  defimpl(String.Chars, do: def(to_string(impl), do: "#{TypeImpl.code(impl)}"))
  defimpl(ToCode, do: def(to_code(impl), do: "#{impl}"))
end
