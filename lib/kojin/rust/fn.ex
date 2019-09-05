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

  @doc ~s"""

  If passed `Type`, it is returned.

  ## Example

      iex> import Kojin.Rust.Parm
      ...> String.Chars.to_string(parm(parm(parm(:a, :i32))))
      "a: i32"  

  Special `self` parameters.

  ## Example

      iex> import Kojin.Rust.Parm
      ...> String.Chars.to_string(parm(:self))
      "self: Self"

      iex> import Kojin.Rust.Parm
      ...> String.Chars.to_string(parm(:self_ref))
      "self: & Self"

      iex> import Kojin.Rust.Parm
      ...> String.Chars.to_string(parm(:self_mref))
      "self: & mut Self"      

  To associate lifetimes to `self` use `parm(:self, ref(:self, :a))`
  or `parm(:self, ref(:self, :b))`

  ## Example

      iex> import Kojin.Rust.{Parm, Type}
      ...> String.Chars.to_string(parm(:self, ref(:self, :a)))
      "self: & 'a Self"

      iex> import Kojin.Rust.{Parm, Type}
      ...> String.Chars.to_string(parm(:self, mref(:self, :b)))
      "self: & 'b mut Self"      

  """
  def parm(%Parm{} = parm), do: parm

  def parm(:self), do: parm(:self, :self)

  def parm(:self_ref), do: parm(:self, Type.ref(:self))

  def parm(:self_mref), do: parm(:self, Type.mref(:self))
  def parm([name, type, doc]) when is_binary(doc), do: parm(name, type, doc: doc)
  def parm([name, type | opts]), do: parm(name, type, opts)

  @doc ~s"""

  Creates parameter with `name` and `type` specified.

  Options:

  - `doc`: Documentation for parameter
  - `mut`: If set parameter is _mutable_ (default `false`)

  ## Example

      iex> import Kojin.Rust.Parm
      ...> String.Chars.to_string(parm(:size, :i32, doc: "Size in bytes"))
      "size: i32"    

      iex> import Kojin.Rust.Parm
      ...> String.Chars.to_string(parm(:size, :i32, "Size in bytes"))
      "size: i32"    

      iex> import Kojin.Rust.Parm
      ...> String.Chars.to_string(parm(:size, :i32, mut: true))
      "mut size: i32"  

  """
  def parm(name, type, opts \\ [])

  def parm(name, type, doc) when is_binary(doc), do: parm(name, type, doc: doc)

  def parm(name, type, opts) do
    defaults = [mut: false, doc: "TODO: Comment #{name}"]
    opts = Kojin.check_args(defaults, opts)

    result = %Parm{
      name: name,
      type: Type.type(type),
      doc: opts[:doc],
      mut: opts[:mut]
    }

    result
  end

  @doc ~s"""
  Returns param with `type` that corresponds to name.

  ## Examples

      iex> import Kojin.Rust.Parm
      ...> id_parm(:some_type, doc: "Some type", mut: true)
      import Kojin.Rust.{Parm, Type}; parm(:some_type, :some_type, doc: "Some type", mut: true)
  """
  def id_parm(name, rest), do: parm(name, name |> Kojin.Id.cap_camel(), rest)

  @doc ~s"""
  Returns param with `type` that is a ref to corresponding name.

  ## Examples

      iex> import Kojin.Rust.Type
      ...> ref_parm(:some_type, doc: "Reference to some type", mut: false)
      import Kojin.Rust.{Parm, Type}; parm(:some_type, ref(:some_type), doc: "Reference to some type", mut: false)
  """
  def ref_parm(name, rest), do: parm(name, ref(name |> Kojin.Id.cap_camel()), rest)

  @doc ~s"""
  Returns param with `type` that is a mref to corresponding name.

  ## Examples

      iex> import Kojin.Rust.Type
      ...> mref_parm(:some_type, "Reference to some type")
      import Kojin.Rust.{Parm, Type}; parm(:some_type, mref(:some_type), "Reference to some type")
  """
  def mref_parm(name, rest), do: parm(name, mref(name |> Kojin.Id.cap_camel()), rest)

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
  import Kojin.{CodeBlock, Id, Utils, Rust.Type}
  alias Kojin.CodeBlock
  alias Kojin.Rust.{Fn, Generic, Parm, ToCode, Type}

  @typedoc """
  A rust function.

    - `name`: Name of the function (snake case atom)
    - `doc`: Comment associated with function (string)
    - `parms`: List of parameters
    - `return`: Return type of function (Kojin.Rust.Type.t())
    - `return_doc`: Comment associated with return value
    - `inline`: Indicates function is `#[inline]`
    - `generic`: Details of generic for function
    - `consts`: TODO
    - `code_block`: The protection block for the function
    - `tag_prefix`: A prefix for the code block tag to ensure unique in generated context
    - `visibility`: One of the visibility designations (`Kojin.Rust.allowed_visibilities`)
    - `body`: The body of the function
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:parms, list(Parm.t()))
    field(:return, Kojin.Rust.Type.t())
    field(:return_doc, String.t())
    field(:inline, boolean, default: false)
    field(:generic, Generic.t(), default: nil)
    field(:consts, Kojin.Rust.Const.t())
    field(:code_block, Kojin.CodeBlock.t(), default: nil)
    field(:tag_prefix, String.t(), default: nil)
    field(:visibility, atom)
    field(:body, String.t())
  end

  validates(:visibility, inclusion: Kojin.Rust.allowed_visibilities())

  defp return({t, doc}), do: {type(t), doc}
  defp return(t), do: return({t, nil})

  @doc ~s{
    Returns `f` if it is already a `Fn`

    ## Examples

        iex> import Kojin.Rust.Fn
        ...> fun(fun(:f, "This is function f", []))
        import Kojin.Rust.Fn; fun(:f, "This is function f", [])
  }
  @spec fun(Fn.t()) :: Fn.t()
  def fun(%Fn{} = f), do: f

  @doc ~s"""
  Support passing list of arguments to fun/4.

  ## Examples

    If five args provided the last two assumed `return` and `return_doc`

      iex> import Kojin.Rust.Fn
      ...> fun([:foo, "foo docs", [], :i32, "returns age"])
      import Kojin.Rust.Fn; fun(:foo, "foo docs", [], return: :i32, return_doc: "returns age")

    If four args and fourth is `Keyword` list, it is assumed `options`

      iex> import Kojin.Rust.Fn
      ...> fun([:foo, "foo docs", [], [return: :i64]])
      import Kojin.Rust.Fn; fun(:foo, "foo docs", [], return: :i64)

    Otherwise, if four args, assume last is `return`

      iex> import Kojin.Rust.Fn
      ...> fun([:foo, "foo docs", [[:parm1, :i32]], :i64])
      import Kojin.Rust.Fn; fun(:foo, "foo docs", [[:parm1, :i32]], :i64)
  """
  @spec fun(list) :: Fn.t()
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

  @spec fun(binary | atom, binary, list(Parm.t()), list) :: Fn.t()

  def fun(name, doc, parms, rest) when is_binary(name),
    do: fun(String.to_atom(name), doc, parms, rest)

  def fun(name, doc, parms, return) when not is_list(return),
    do: fun(name, doc, parms, return: return)

  def fun(name, doc, parms, opts) when is_list(opts) do
    defaults = [
      __struct__: nil,
      return: nil,
      return_doc: "",
      inline: false,
      generic: nil,
      consts: [],
      tag_prefix: nil,
      code_block: nil,
      body: nil,
      visibility: :private
    ]

    opts = Kojin.check_args(defaults, opts)
    {return, return_doc} = return(opts[:return])

    code_block =
      if(opts[:body]) do
        nil
      else
        CodeBlock.code_block("fn #{snake(name)}", tag_prefix: opts[:tag_prefix])
      end

    return_doc =
      if(!return_doc) do
        opts[:return_doc]
      else
        return_doc
      end

    result = %Fn{
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
      code_block: code_block,
      tag_prefix: opts[:tag_prefix],
      visibility: opts[:visibility],
      body: opts[:body]
    }

    if(!Vex.valid?(result)) do
      raise ArgumentError,
        message: """
        Invalid `fn`:
        #{inspect(result, pretty: true)}
        ------- Fn Validations ---
        #{inspect(Vex.results(result), pretty: true)}
        """
    end

    result
  end

  @doc ~s"""
    Converts `return` and `return_doc` into options and calls fun/4.
  """
  @spec fun(binary | atom, binary, list(Parm.t()), binary | atom | Type.t(), binary) ::
          Kojin.Rust.Fn.t()
  def fun(name, doc, parms, return, return_doc),
    do: fun(name, doc, parms, return: return, return_doc: return_doc)

  @doc ~s"""
  Return new `Kojin.Rust.Fn` with specified `tag_prefix`.

  ## Examples

      iex> import Kojin.Rust.Fn
      ...> fun_with_tag_prefix(fun(:f, "f doc", [], tag_prefix: "goo"), "foo").tag_prefix
      "foo"
  """
  def fun_with_tag_prefix(%Fn{} = f, tag_prefix) do
    Fn.fun(
      f.name,
      f.doc,
      f.parms,
      Keyword.put(Keyword.drop(Map.to_list(f), [:name, :doc, :parms]), :tag_prefix, tag_prefix)
    )
  end

  @doc ~s"""
  Returns the code definition of the function, including the `signature`
  but excluding the `doc`.

  ## Examples

      iex> alias Kojin.Rust.Fn
      ...> Fn.code(Fn.fun(:f, "Comment")) |> Kojin.dark_matter
      ~s[
      fn f() {
        // α <fn f>
        // ω <fn f>
      }
      ] |> Kojin.dark_matter

      iex> alias Kojin.Rust.Fn
      ...> Fn.code(Fn.fun(:f, "Comment", [], tag_prefix: "Prefix::")) |> Kojin.dark_matter
      ~s[
      fn f() {
        // α <Prefix::(fn f)>
        // ω <Prefix::(fn f)>
      }
      ] |> Kojin.dark_matter

    With body instead of protect block:

      iex> alias Kojin.Rust.Fn
      ...> Fn.code(Fn.fun(:f, "Comment", [], body: "42", return: :i32)) |> Kojin.dark_matter
      ~s[
      fn f() -> i32 {
        42
      }
      ] |> Kojin.dark_matter
  """
  def code(fun) do
    [
      "#{signature(fun)} {",
      if(fun.body) do
        indent_block(fun.body)
      else
        indent_block(text(fun.code_block))
      end
      |> String.trim_trailing(),
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
  @spec signature(Fn.t()) :: binary
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

    visibility = Kojin.Rust.visibility_decl(fun.visibility)

    {generic, bounds_decl} =
      if(fun.generic) do
        {Generic.code(fun.generic), Generic.bounds_decl(fun.generic)}
      else
        {"", ""}
      end

    "#{inline}#{visibility}fn#{generic} #{snake(fun.name)}(#{parms})#{rt}#{bounds_decl}"
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
        |> Enum.filter(fn parm -> parm.name not in [:self, :self_ref, :self_mref] end)
        |> Enum.map(fn parm -> "* `#{parm.name}` - #{parm.doc}" end),
        return_doc
      ]
      |> List.flatten()
      |> Enum.join("\n")

    join_content(
      [
        if String.length(fun.doc) > 0 do
          "#{fun.doc}" |> String.trim_trailing()
        else
          "TODO: document #{fun.name}"
        end,
        signature_docs
      ],
      "\n\n"
    )
    |> triple_slash_comment()
  end

  defimpl(String.Chars, do: def(to_string(fun), do: join_content([Fn.doc(fun), Fn.code(fun)])))

  defimpl ToCode do
    @spec to_code(Fn.t()) :: binary
    def to_code(fun), do: "#{fun}"
  end
end
