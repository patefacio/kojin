defmodule Kojin.Rust.CargoToml do
  use TypedStruct
  use Vex.Struct

  typedstruct do
    field(:name, atom, enforce: true)
    field(:description, String.t(), enforce: true)
    field(:version, String.t(), default: "0.0.1")
    field(:authors, list(String.t()), default: [])
    field(:homepage, String.t(), default: nil)
    field(:license, String.t(), default: "MIT")
  end

  def generate(cargo_toml, path) do
    toml = ~s"""
    [package]
    name = "#{cargo_toml.name}"
    version = "#{cargo_toml.version}"
    authors = [#{cargo_toml.authors |> Enum.join()}]
    description = \"\"\"#{cargo_toml.description}\"\"\"
    keywords = []
    license = "#{cargo_toml.license}"

    [dependencies]
    itertools = "^0.7.6"
    serde = "^1.0.27"
    serde_derive = "^1.0.27"
    #{Kojin.CodeBlock.script_block("dependencies")}
    """

    Kojin.merge_generated_with_file(toml, path, Kojin.CodeBlock.script_delimiters())
  end
end

defmodule Kojin.Rust.Crate do
  import Kojin
  alias Kojin.Rust
  alias Rust.{Crate, Module, GeneratedRustModule, CargoToml}
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

    opts =
      Keyword.merge(
        [
          version: "0.0.1",
          authors: [],
          homepage: nil,
          license: "MIT",
          binaries: []
        ],
        opts
      )

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
        license: opts[:license]
      }
    }
  end

  def generate({crate, generate_spec}) do
    path = generate_spec.path
    File.cd!(path)

    src_path = Path.join([path, "src"])

    if(!File.exists?(src_path)) do
      File.mkdir_p!(src_path)
    end

    # Generate the cargo
    CargoToml.generate(crate.cargo_toml, Path.join([path, "Cargo.toml"]))

    # Generate the code
    generated = Module.generate(crate.root_module, %{generate_spec | path: src_path})

    # Format the code
    result = Porcelain.shell("cargo fmt")
    Logger.debug("`cargo fmt` result -> #{inspect(result)}")

    # Report on diffs (if no change set timestamp back to original)
    generated
    |> Enum.each(fn {path, generated_rust_module} ->
      Logger.debug("Generating #{path}")
      GeneratedRustModule.evaluate_formatted_diff(generated_rust_module)
    end)
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
