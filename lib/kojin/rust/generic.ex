import Kojin

defmodule Kojin.Rust.TypeParm do
  require Logger
  use TypedStruct
  use Vex.Struct

  alias Kojin.Rust.{TypeParm, Type, Bounds}
  import Kojin.{Id, Utils}

  @typedoc """
  A type parm for a generic
  """
  typedstruct enforce: true do
    field(:name, binary())
    field(:id, atom)
    field(:default_type, Type.t())
    field(:bounds, Bounds.t())
  end

  def type_parm(%TypeParm{} = type_parm), do: type_parm

  def type_parm([name | opts]), do: type_parm(name, opts)

  def type_parm(name, opts \\ [])

  # TODO: Maybe remove this flexibility
  def type_parm(id, opts) when is_atom(id) do
    Logger.debug("type parm name -> #{id} opts -> #{inspect(opts)}")

    defaults = [default_type: nil, bounds: []]
    opts = check_args(defaults, opts)

    %TypeParm{
      id: id,
      name: cap_camel(id),
      default_type: Type.type(opts[:default_type]),
      bounds: Bounds.bounds(opts[:bounds])
    }
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

    "#{type_parm.name}#{default_type}"
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

  alias Kojin.Rust.{Generic, TypeParm, Bounds}
  import Kojin.Utils

  @typedoc """
  A generic
  """
  typedstruct enforce: true do
    field(:type_parms, list(binary()), default: [])
    field(:lifetimes, list(char()), default: [])
  end

  def generic(%Generic{} = generic), do: generic

  def generic([type_parms | opts]) when is_list(type_parms), do: generic(type_parms, opts)

  @doc """
  Creates generic when given type parms plus additional options
  """
  def generic(type_parms, opts \\ []) when is_list(type_parms) do
    Logger.debug("Generic Opts #{inspect(type_parms)} -> #{inspect(opts)}")
    opts = check_args([lifetimes: []], opts)

    %Generic{
      type_parms:
        type_parms
        |> Enum.map(fn tp ->
          TypeParm.type_parm(tp)
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
      join_content([
        "\nwhere",
        indent_block(
          join_content(
            generic.type_parms
            |> Enum.filter(fn type_parm -> !Bounds.empty?(type_parm.bounds) end)
            |> Enum.map(fn type_parm -> TypeParm.bounds_decl(type_parm) |> IO.inspect() end)
          )
        )
      ])
      |> IO.inspect()
    else
      ""
    end
  end

  def code(%Generic{} = generic) do
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
