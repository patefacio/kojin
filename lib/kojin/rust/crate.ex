defmodule Kojin.Rust.Crate do
  import Kojin
  import Kojin.{Id, Utils}
  alias Kojin.Rust
  alias Rust.{Crate, Module}
  use TypedStruct
  use Vex.Struct

  @typedoc """
  A rust _module_.
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:modules, list(Module.t()), default: [])
    field(:version, String.t(), default: "0.0.1")
    field(:authors, list(String.t()), default: [])
    field(:homepage, String.t(), default: nil)
    field(:license, String.t(), default: "MIT")
  end

  def crate(name, doc, modules, opts \\ []) do
    require_snake(name)

    opts =
      Keyword.merge(
        [
          version: "0.0.1",
          authors: [],
          homepage: nil,
          license: "MIT"
        ],
        opts
      )

    %Crate{
      name: name,
      doc: doc,
      modules: modules,
      version: opts[:version],
      authors: opts[:authors],
      homepage: opts[:homepage],
      license: opts[:license]
    }
  end

  def generate({crate, generate_spec}) do
    # my_module = generate_spec.path

    IO.puts("BADABING cratex #{inspect(generate_spec, pretty: true)}")

    crate.modules
    |> Enum.reduce(%{}, fn module, acc ->
      Map.merge(
        acc,
        Module.generate(module, generate_spec)
      )
    end)

    # IO.puts("Content -> #{inspect(content, pretty: true)}")
  end

  def generate_spec(crate, path) do
    {
      crate,
      %Rust.GenerateSpec{
        path: path
      }
    }
  end
end
