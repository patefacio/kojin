require Logger

defmodule Kojin.Rust.Binary do
  use TypedStruct
  use Vex.Struct

  alias Kojin.Rust.{Module, Clap}
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

  def binary(id, doc, opts \\ []) when is_atom(id) do
    defaults = [
      clap: nil,
      submodules: []
    ]

    opts = Kojin.check_args(defaults, opts)
    clap = opts[:clap]

    structs =
      if(clap) do
        [Clap.clap_struct(clap)]
      else
        []
      end

    module = Module.module(id, doc, structs: structs, modules: opts[:submodules], is_binary: true)
    IO.inspect(module)

    %Binary{
      id: id,
      doc: doc,
      clap: opts[:clap],
      module: module
    }
  end
end
