require Logger

defmodule Kojin.Rust.Binary do
  use TypedStruct
  use Vex.Struct

  import Kojin.Id
  alias Kojin.Rust.{Module, Clap, Fn}
  alias Kojin.Rust.Binary

  @typedoc """
  A rust binary application.
  """
  typedstruct enforce: true do
    field(:id, binary())
    field(:doc, binary())
    field(:clap, Clap.t() | nil)
    field(:module, Module.t())
  end

  def binary(id, doc, opts \\ [])
  def binary(id, doc, opts) when is_atom(id), do: binary(Atom.to_string(id), doc, opts)

  def binary(id, doc, opts) when is_binary(id) and is_binary(doc) do
    defaults = [
      clap: nil,
      submodules: []
    ]

    opts = Kojin.check_args(defaults, opts)
    clap = opts[:clap]
    clap_struct_id = "#{id}_opts"
    clap_structs = if clap, do: [Clap.clap_struct(clap, clap_struct_id)], else: []
    clap_enums = if clap, do: [Clap.clap_enums(clap)], else: []

    main_fn =
      Fn.fun(:main, "Entry point for #{id}", [],
        pre_block:
          if clap do
            """
            let opts = #{cap_camel(clap_struct_id)}::parse();
            println!("{:?}", opts)
            """
          end
      )

    module =
      Module.module(id, doc,
        structs: clap_structs,
        modules: opts[:submodules],
        is_binary: true,
        type: :file,
        functions: [main_fn] |> Enum.reject(&is_nil/1),
        enums: clap_enums
      )

    %Binary{
      id: id,
      doc: doc,
      clap: opts[:clap],
      module: module
    }
  end
end
