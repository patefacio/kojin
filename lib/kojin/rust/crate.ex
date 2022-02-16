defmodule Kojin.Rust.CargoToml do
  use TypedStruct
  use Vex.Struct
  alias Kojin.Rust.CargoToml

  typedstruct do
    field(:name, atom, enforce: true)
    field(:description, String.t(), enforce: true)
    field(:version, String.t(), default: "0.0.1")
    field(:authors, list(String.t()), default: [])
    field(:homepage, String.t(), default: nil)
    field(:license, String.t(), default: "MIT")
    field(:dependencies, String.t(), default: [])
  end

  @spec cargo_toml_content(Kojin.Rust.CargoToml.t()) :: binary
  def cargo_toml_content(%CargoToml{} = cargo_toml) do
    ~s"""
    [package]
    edition = "2018"
    name = "#{cargo_toml.name}"
    version = "#{cargo_toml.version}"
    authors = [#{cargo_toml.authors |> Enum.join()}]
    description = \"\"\"#{cargo_toml.description}\"\"\"
    keywords = []
    license = "#{cargo_toml.license}"

    [dependencies]
    itertools = "^0.7.6"
    #{Enum.join(cargo_toml.dependencies, "\n")}
    #{Kojin.CodeBlock.script_block("dependencies")}
    """
  end
end

defmodule Kojin.Rust.Crate do
  import Kojin
  alias Kojin.Rust
  alias Rust.{Crate, Module, CargoToml}

  use TypedStruct
  use Vex.Struct
  require Logger

  @typedoc """
  A rust _module_.
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:root_module, Module.t())
    field(:binaries, default: [])
    field(:cargo_toml, CargoToml.t())
  end

  def crate(name, doc, root_module, opts \\ []) do
    require_snake(name)

    defaults = [
      version: "0.0.1",
      authors: [],
      homepage: nil,
      license: "MIT",
      binaries: [],
      dependencies: []
    ]

    opts =
      Kojin.check_args(
        defaults,
        opts
      )

    root_module = if(root_module.name != "lib") do
      raise "Root module must be named `lib` not #{root_module.name}"
    else
      root_module
    end

    %Crate{
      name: name,
      doc: doc,
      root_module: root_module,
      binaries: opts[:binaries],
      cargo_toml: %Rust.CargoToml{
        name: name,
        description: doc,
        version: opts[:version],
        authors: opts[:authors],
        homepage: opts[:homepage],
        license: opts[:license],
        dependencies: opts[:dependencies]
      }
    }
  end
end
