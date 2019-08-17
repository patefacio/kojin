defmodule Kojin.Rust.Parm do
  use TypedStruct
  use Vex.Struct

  import Kojin.Rust.Type
  import Kojin.Id
  alias Kojin.Rust.{Type, Parm, ToCode}

  @typedoc """
  A rust function parm.
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:type, Type.t(), enforce: true, default: :double)
    field(:doc, String.t())
    field(:mut, boolean(), default: false)
  end

  @doc """
  Returns the code associated with the parameter.

  ## Examples

      iex> import Kojin.Rust.Parm
      ...> code(parm(:result, "Result<i32, Err>", doc: "The first result parameter", mut: true))
      "mut result: Result<i32, Err>"
  """
  def code(parm) do
    mutable =
      if(parm.mut) do
        "mut "
      else
        ""
      end

    "#{mutable}#{snake(parm.name)}: #{Type.code(parm.type)}"
  end

  def parm(%Parm{} = parm), do: parm
  def parm([name, type | opts]), do: parm(name, type, opts)

  def parm(name, type, opts \\ [])
  def parm(name, type, doc) when is_binary(doc), do: parm(name, type, doc: doc)

  def parm(name, type, opts) do
    defaults = [mut: false, doc: "TODO: Comment #{name}"]
    opts = Keyword.merge(defaults, opts)

    result = %Parm{
      name: name,
      type: Type.type(type),
      doc: opts[:doc],
      mut: opts[:mut]
    }

    result
  end

  defimpl String.Chars do
    def to_string(parm) do
      Parm.code(parm)
    end
  end
end

defmodule Kojin.Rust.Fn do
  @moduledoc """
  Rust _fn_ definition.

  Provides support for _modeling_ functions.
  """

  use TypedStruct
  use Vex.Struct
  import Kojin
  import Kojin.{CodeBlock, Id, Utils, Rust.Type}
  alias Kojin.CodeBlock
  alias Kojin.Rust.{Fn, Generic, Parm, ToCode}

  @typedoc """
  A rust function.

    - `name`: Name of the function (snake case atom)
    - `doc`: Comment associated with function (string)
    - `parms`: List of parameters
    - `return`: Return type of function (Kojin.Rust.Type.t())
    - `return_doc`: Comment associated with return value
    - `generic`: Details of generic for function
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:parms, list(Parm.t()))
    field(:return, Kojin.Rust.Type.t())
    field(:return_doc, String.t())
    field(:inline, boolean(), default: false)
    field(:generic, Generic.t(), default: nil)
    field(:consts, Kojin.Rust.Const.t())
    field(:code_block, Kojin.CodeBlock.t())
  end

  defp return({t, doc}), do: {type(t), doc}
  defp return(t), do: return({t, nil})

  @doc ~s{
    Returns `f` if it is a `Fn`
  }
  def fun(%Fn{} = f), do: f

  def fun([name, doc, parms, return, return_doc]), do: fun(name, doc, parms, return, return_doc)

  def fun([name, doc, parms, opts]) when is_list(opts), do: fun(name, doc, parms, opts)

  def fun([name, doc, parms, return]), do: fun(name, doc, parms, return)

  @doc ~s"""
  Create `Fn` instance.

  - `name`: Name of function (snake case)
  - `doc`: Documentation of function
  - `parms`: List of function parameters
  - `opts`: Additional options for funciton
    - `return`: Type returned by function
    - `return_doc`: Documentation of value returned
    - `inline`: If true annotates function as inline
    - `generic`: Details of generics of function
    - `consts`: List of constants of the function
    - `code_block_prefix`: Prepended to function name in code block tag

  ## Examples

      iex> import Kojin.Rust.Fn
      ...> signature(fun(:f, "Simple function", [], return: :i32, return_doc: "Latest value of f"))
      "fn f() -> i32"

  """
  def fun(name, doc, parms \\ [], opts \\ [])

  def fun(name, doc, parms, rest) when is_binary(name),
    do: fun(String.to_atom(name), doc, parms, rest)

  def fun(name, doc, parms, return) when not is_list(return),
    do: fun(name, doc, parms, return: return)

  def fun(name, doc, parms, opts) when is_list(opts) do
    defaults = [
      return: nil,
      return_doc: "",
      inline: false,
      generic: nil,
      consts: [],
      code_block_prefix: ""
    ]

    opts = Keyword.merge(defaults, opts)
    {return, return_doc} = return(opts[:return])

    code_block = CodeBlock.code_block("fn #{opts[:code_block_prefix]}#{snake(name)}")

    return_doc =
      if(!return_doc) do
        opts[:return_doc]
      else
        return_doc
      end

    %Fn{
      name: name,
      doc: doc,
      parms: Enum.map(parms, fn parm -> Parm.parm(parm) end),
      return: return,
      return_doc: return_doc,
      inline: opts[:inline],
      generic:
        if(opts[:generic] != nil) do
          Generic.generic(opts[:generic])
        else
          nil
        end,
      consts: opts[:consts],
      code_block: code_block
    }
  end

  @doc ~s{
    Converts *return* and `return_doc` into options and calls fun/4.
  }
  @spec fun(any, any, any, any, any) :: Kojin.Rust.Fn.t()
  def fun(name, doc, parms, return, return_doc),
    do: fun(name, doc, parms, return: return, return_doc: return_doc)

  @doc """
  Returns the code definition of the function, including the signature.
  """
  def code(fun, prefix \\ "") do
    [
      "#{signature(fun)} {",
      indent_block(text(fun.code_block)),
      "}"
    ]
    |> join_content("\n")
  end

  @doc ~s"""
  Returns signature of function.

  ## Examples

      iex> import Kojin.Rust.Fn
      ...> signature(fun(:f, "Simple function", [], return: :i32, return_doc: "Latest value of f"))
      "fn f() -> i32"

  """
  @spec signature(Fn.type()) :: binary
  def signature(fun) do
    rt =
      if(fun.return != nil) do
        " -> #{type(fun.return)}"
      else
        ""
      end

    parms =
      fun.parms
      |> Enum.map(fn parm -> Parm.code(parm) end)
      |> Enum.join(", ")

    inline =
      if(fun.inline) do
        "#[inline]\n"
      else
        ""
      end

    {generic, bounds_decl} =
      if(fun.generic) do
        {Generic.code(fun.generic), Generic.bounds_decl(fun.generic)}
      else
        {"", ""}
      end

    "#{inline}fn#{generic} #{snake(fun.name)}(#{parms})#{rt}#{bounds_decl}"
  end

  @doc ~s"""
  Return doc comment and signature of function.

  ## Examples

      iex> import Kojin.Rust.Fn
      ...> commented_signature(fun(:f, "This is an f", []))
      "///  This is an f\\nfn f()"

  """
  def commented_signature(fun), do: join_content([Fn.doc(fun), Fn.signature(fun)])

  @doc ~s"""
  Return the function as would appear in a trait, with comment and trailing semicolon.

  ## Examples

      iex> import Kojin.Rust.Fn
      ...> trait_signature(fun(:f, "This is an f", []))
      "///  This is an f\\nfn f();"

  """
  def trait_signature(fun), do: "#{commented_signature(fun)};"

  @doc ~s"""
  Returns the block comment of `doc` associated with function.

  ## Examples

      iex> import Kojin.Rust.Fn
      ...> doc(fun(:f, "A basic function"))
      "///  A basic function"
  """
  def doc(fun) do
    return_doc =
      if fun.return do
        if fun.return_doc && fun.return_doc != "" do
          "* _return_ - #{fun.return_doc}\n"
        else
          "* _return_ - TODO: document return\n"
        end
      else
        ""
      end

    signature_docs =
      [
        fun.parms
        |> Enum.map(fn parm -> "* `#{parm.name}` - #{parm.doc}" end),
        return_doc
      ]
      |> List.flatten()
      |> Enum.join("\n")

    triple_slash_comment(
      if String.length(fun.doc) > 0 do
        "#{fun.doc}"
      else
        "TODO: document #{fun.name}"
      end <>
        "\n\n#{signature_docs}"
    )
  end

  defimpl(String.Chars, do: def(to_string(fun), do: join_content([Fn.doc(fun), Fn.code(fun)])))
  defimpl(ToCode, do: def(to_code(fun), do: "#{fun}"))
end
