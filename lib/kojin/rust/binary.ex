require Logger

defmodule Kojin.Rust.Arg do
  use TypedStruct
  use Vex.Struct

  alias Kojin.Rust.{Arg, Type}

  typedstruct enforce: true do
    field(:name, atom)
    field(:doc, String.t())
    field(:short, String.t())
    field(:type, Type.t(), default: Type.type(:string))
    field(:is_required, boolean, default: false)
    field(:is_multiple, boolean, default: false)
    field(:default_value, String.t(), default: nil)
  end

  def arg(name, doc, opts \\ []) when is_atom(name) and is_binary(doc) do
    defaults = [
      short: nil,
      doc: doc,
      type: Type.type(:string),
      is_required: false,
      is_multiple: false
    ]

    opts =
      Kojin.check_args(
        defaults,
        opts
      )

    %Arg{
      name: name,
      doc:
        if opts[:doc] do
          opts[:doc]
        else
          "TODO: Document binary arg `#{name}`"
        end,
      short: opts[:short],
      type: Type.type(opts[:type]),
      is_required: opts[:is_required],
      is_multiple: opts[:is_multiple],
      default_value: opts[:default_value]
    }
  end
end

defmodule Kojin.Rust.Binary do
  use TypedStruct
  use Vex.Struct

  alias Kojin.Rust.{Module, Arg}

  @typedoc """
  A rust binary application.
  """
  typedstruct enforce: true do
    field(:name, binary())
    field(:module, Module.t())
    field(:args, list(Arg.t()))
  end
end
