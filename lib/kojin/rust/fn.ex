defmodule Kojin.Rust.Parm do
  use TypedStruct
  use Vex.Struct

  import Kojin.Rust.Type
  import Kojin.Id
  alias Kojin.Rust.Type
  alias Kojin.Rust.Parm

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

  def parm(name, type, opts \\ []) do
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
  import Kojin
  import Kojin.Rust.Const
  import Kojin.Rust.Type
  alias Kojin.Rust.Generic
  import Kojin.Id
  import Kojin.Utils
  alias Kojin.Rust.Fn
  alias Kojin.Rust.Parm

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

  def fun(name, doc, parms, opts \\ []) do
    defaults = [return: nil, return_doc: "", inline: false, generic: nil, consts: []]
    opts = Keyword.merge(defaults, opts)

    %Fn{
      name: name,
      doc: doc,
      parms: parms,
      return: type(opts[:return]),
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

  def code(fun) do
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

    """
    #{inline}fn#{generic} #{snake(fun.name)}(#{parms})#{rt}#{bounds_decl} {
    }
    """
  end

  def doc(fun) do
    parmDocs =
      fun.parms
      |> Enum.map(fn parm -> " * `#{parm.name}` #{parm.doc}" end)
      |> Enum.join("\n")

    triple_slash_comment(
      if String.length(fun.doc) > 0 do
        "#{fun.doc}\n\n"
      else
        "TODO: document #{fun.name}"
      end <>
        parmDocs
    )
  end

  defimpl String.Chars do
    def to_string(fun) do
      "#{Fn.doc(fun)}#{Fn.code(fun)}"
    end
  end
end
