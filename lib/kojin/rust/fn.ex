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
  """

  use TypedStruct
  use Vex.Struct
  import Kojin.{Id, Utils, Rust.Type}
  alias Kojin.Rust.{Fn, Generic, Parm, ToCode}

  @typedoc """
  A rust function.
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:parms, list())
    field(:return, Kojin.Rust.Type.t())
    field(:return_doc, String.t())
    field(:inline, boolean(), default: false)
    field(:generic, Generic.t(), default: nil)
    field(:consts, Kojin.Rust.Const.t())
  end

  defp return({t, doc}), do: {type(t), doc}
  defp return(t), do: return({t, nil})

  def fun(%Fn{} = f), do: f

  def fun([name, doc, parms, return, return_doc]), do: fun(name, doc, parms, return, return_doc)

  def fun([name, doc, parms, opts]) when is_list(opts), do: fun(name, doc, parms, opts)

  def fun([name, doc, parms, return]), do: fun(name, doc, parms, return)

  def fun(name, doc, parms \\ [], opts \\ [])

  def fun(name, doc, parms, rest) when is_binary(name),
    do: fun(String.to_atom(name), doc, parms, rest)

  def fun(name, doc, parms, return) when not is_list(return),
    do: fun(name, doc, parms, return: return)

  def fun(name, doc, parms, opts) when is_list(opts) do
    defaults = [return: nil, return_doc: "", inline: false, generic: nil, consts: []]
    opts = Keyword.merge(defaults, opts)
    {return, return_doc} = return(opts[:return])

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
      consts: opts[:consts]
    }
  end

  def fun(name, doc, parms, return, return_doc),
    do: fun(name, doc, parms, return: return, return_doc: return_doc)

  def code(fun) do
    """
    #{signature(fun)} {

    }
    """
  end

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

  def commented_signature(fun), do: "#{Fn.doc(fun)}\n#{Fn.signature(fun)}"

  def trait_signature(fun), do: "#{commented_signature(fun)};"

  def doc(fun) do
    return_doc =
      if fun.return do
        if fun.return_doc && fun.return_doc != "" do
          " * _return_ - #{fun.return_doc}\n"
        else
          " * _return_ - TODO: document return\n"
        end
      else
        ""
      end

    signature_docs =
      [
        fun.parms
        |> Enum.map(fn parm -> " * `#{parm.name}` - #{parm.doc}" end),
        return_doc
      ]
      |> List.flatten()
      |> Enum.join("\n")

    triple_slash_comment(
      if String.length(fun.doc) > 0 do
        "#{fun.doc}\n\n"
      else
        "TODO: document #{fun.name}"
      end <>
        signature_docs
    )
  end

  defimpl(String.Chars, do: def(to_string(fun), do: "#{Fn.doc(fun)}#{Fn.code(fun)}"))
  defimpl(ToCode, do: def(to_code(fun), do: "#{fun}"))
end
