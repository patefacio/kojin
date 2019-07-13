import Kojin

defmodule Kojin.Rust.TypeParm do
  require Logger
  use TypedStruct
  use Vex.Struct

  alias Kojin.Rust.TypeParm
  alias Kojin.Rust.Type
  alias Kojin.Rust.Bounds

  @typedoc """
  A type parm for a generic
  """
  typedstruct enforce: true do
    field(:name, binary(), default: "T")
    field(:default_type, Type.t())
    field(:bounds, Bounds.t())
  end

  def type_parm([name | opts]), do: type_parm(name, opts)

  def type_parm(name, opts \\ [])

  # TODO: Maybe remove this flexibility
  def type_parm(name, opts) when is_binary(name), do: type_parm(String.to_atom(name), opts)

  def type_parm(name, opts) when is_atom(name) do
    Logger.info("type parm name -> #{name} opts -> #{inspect(opts)}")
    opts = check_args([default_type: nil, bounds: []], opts)

    %TypeParm{
      name: name,
      default_type: Type.type(opts[:default_type]),
      bounds: Bounds.bounds(opts[:bounds])
    }
  end

  def name(type_parm) do
    Atom.to_string(type_parm.name)
  end

  def bounds_decl(type_parm) do
    bounds = Kojin.Utils.indent_block("#{type_parm.bounds}")
    "#{type_parm.name}: #{bounds}"
  end

  def code(type_parm) do
    default_type =
      if(type_parm.default_type == nil) do
        ""
      else
        " = #{type_parm.default_type}"
      end

    "#{TypeParm.name(type_parm)}#{default_type}"
  end

  defimpl String.Chars do
    def to_string(type_parm) do
      if type_parm.default_type do
        "#{type_parm.name} = #{type_parm.default_type}"
      else
        type_parm.name
      end
    end
  end
end

defmodule Kojin.Rust.Generic do
  require Logger
  use TypedStruct
  use Vex.Struct

  alias Kojin.Rust.Generic
  alias Kojin.Rust.TypeParm
  alias Kojin.Rust.Bounds

  @typedoc """
  A generic
  """
  typedstruct enforce: true do
    field(:type_parms, list(binary()), default: [])
    field(:lifetimes, list(char()), default: [])
  end

  def generic([type_parms | opts]) when is_list(type_parms), do: generic(type_parms, opts)

  @doc """
  Creates generic when given type parms plus additional options
  """
  def generic(type_parms, opts \\ []) when is_list(type_parms) do
    Logger.info("Generic Opts #{inspect(type_parms)} -> #{inspect(opts)}")
    opts = check_args([lifetimes: []], opts)

    %Generic{
      type_parms:
        type_parms
        |> Enum.map(fn tp ->
          TypeParm.type_parm(listify(tp))
        end),
      lifetimes: opts[:lifetimes]
    }
  end

  defp has_bounded_types(generic) do
    generic.type_parms
    |> Enum.find(fn tp -> !Bounds.empty?(tp.bounds) end) !=
      nil
  end

  def bounds_decl(generic) do
    if(has_bounded_types(generic)) do
      generic.type_parms
      |> Enum.filter(fn type_parm -> !Bounds.empty?(type_parm.bounds) end)
      |> (&([
              "\nwhere\n",
              Enum.map(&1, fn type_parm -> type_parm |> TypeParm.bounds_decl() end)
            ]
            |> Enum.join())).()
    else
      ""
    end
  end

  def code(generic) do
    [
      "<",
      [
        [
          generic.lifetimes
          |> Enum.map(fn lifetime -> "'#{lifetime}" end)
        ],
        [
          generic.type_parms
          |> Enum.map(fn tp -> TypeParm.code(tp) end)
        ]
      ]
      |> List.flatten()
      |> Enum.join(", "),
      ">"
    ]
    |> Enum.join("")
  end

  defimpl String.Chars do
    def to_string(generic), do: Generic.code(generic)
  end
end
