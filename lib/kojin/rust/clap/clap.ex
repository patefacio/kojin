defmodule Kojin.Rust.Clap do
  use EnumType
  use TypedStruct

  alias Kojin.Rust.{Clap, Field}
  import Kojin.Rust.{Struct, Type, TypeImpl, Parm}

  @typedoc """
  Defines Clap argument set
  """
  typedstruct enforce: true do
    field(:doc, String.t())
    field(:args, list(Arg.t()))
    field(:use_struct, boolean())
  end

  def clap(doc, args, opts \\ []) do
    defaults = [
      use_struct: false
    ]

    opts = Kojin.check_args(defaults, opts)

    %Clap{
      doc: doc,
      args: args,
      use_struct: opts[:use_struct]
    }
  end

  def clap_struct(%Clap{} = clap, clap_struct_id \\ :clap_options) do
    clap_struct =
      struct(
        clap_struct_id,
        clap.doc,
        clap.args
        |> Enum.map(fn arg ->
          Field.field(arg.id, (if arg.type == :str, do: ref(arg.type, :a), else: arg.type), arg.doc)
         end),
        impl:
          type_impl(
            clap_struct_id,
            [
              Kojin.Rust.Fn.fun(:from_matches, "Create #{clap_struct_id} from arguments", [
                parm(:matches, ref("clap::ArgMatches", :a), "This is an a")
                  ],
                return: "ClapOptions<'a>",
                return_doc: "Struct with options pulled from arguments"
              )
            ]
          ),
        generic: [ lifetimes: [:a] ],
        uses: ["clap::Parser"]
      )

    clap_struct
  end
end
