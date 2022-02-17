defmodule Kojin.Rust.Clap do
  use EnumType
  use TypedStruct

  alias Kojin.Rust.{Clap, Clap.Arg, Field, Attr, Type, SimpleEnum}
  import Kojin.Rust.{Struct, Type, TypeImpl, Parm}
  import Kojin.Id

  @typedoc """
  Defines Clap argument set
  """
  typedstruct enforce: true do
    field(:args, list(Arg.t()))
  end

  def clap(args, opts \\ []) do
    %Clap{
      args: args
    }
  end

  def has_enum(%Arg{} = arg), do: !Enum.empty?(arg.enum_values)
  def has_enums(%Clap{} = clap), do: Enum.any?(clap.args, fn arg -> has_enum(arg) end)

  def clap_enums(%Clap{} = clap) do
    clap.args
    |> Enum.filter(&has_enum/1)
    |> Enum.map(fn arg ->
      SimpleEnum.enum(arg.id, arg.doc, arg.enum_values, derivables: [:debug, :arg_enum, :clone ])
    end)
  end

  def clap_struct(%Clap{} = clap, clap_struct_id \\ :clap_options) do
    struct(
      clap_struct_id,
      "Command line arguments for binary",
      clap.args
      |> Enum.map(fn arg ->
        type =
          cond do
            !Enum.empty?(arg.enum_values) -> cap_camel(arg.id)
            arg.is_multiple -> "Vec<#{Type.type(arg.type)}>"
            arg.is_optional -> "Option<#{Type.type(arg.type)}>"
            true -> arg.type
          end

        Field.field(
          arg.id,
          type,
          arg.doc,
          attrs: Arg.attributes(arg)
        )
      end),
      derivables: [:parser, :debug],
      uses: ["clap::Parser", (if has_enums(clap), do: "clap::ArgEnum")] |> Enum.reject(&is_nil/1)
    )
  end
end
