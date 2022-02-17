require Logger

defmodule Kojin.Rust.CrateGenerateSpec do
  use TypedStruct
  alias Kojin.Rust
  alias Rust.{Crate, CrateGenerateSpec}

  typedstruct enforce: true do
    field(:crate, Crate.t())
    field(:crate_path, String.t())
    field(:tmp_path, String.t())
  end

  @spec crate_generate_spec(Kojin.Rust.Crate.t(), binary) :: Kojin.Rust.CrateGenerateSpec.t()
  def crate_generate_spec(%Crate{} = crate, crate_path) do
    src_path = Path.join([crate_path, "src"])
    use_tmp = File.exists?(src_path)

    tmp_path =
      if(use_tmp) do
        new_tmp_path = Temp.mkdir!("#{crate.name}")
        File.mkdir_p!(Path.join([new_tmp_path, "src"]))
        new_tmp_path
      else
        File.mkdir_p!(src_path)
        nil
      end

    %CrateGenerateSpec{
      crate: crate,
      crate_path: crate_path,
      tmp_path: tmp_path
    }
  end

  def absolute_target_path(%CrateGenerateSpec{} = crate_generate_spec, relative_path) do
    if(crate_generate_spec.tmp_path) do
      Path.join([crate_generate_spec.tmp_path, relative_path])
    else
      Path.join([crate_generate_spec.crate_path, relative_path])
    end
  end
end

defmodule Kojin.Rust.CrateGenerator do
  alias Kojin.Rust.{Crate}
  import Kojin.Rust.{CrateGenerateSpec, ModuleGenerateSpec, ModuleGenerator, CargoToml}

  @spec generate_crate(Kojin.Rust.Crate.t(), binary) :: any
  def generate_crate(%Crate{} = crate, crate_path) do
    crate_generate_spec = crate_generate_spec(crate, crate_path)

    %{tmp_path: tmp_path, crate_path: crate_path} = crate_generate_spec

    is_using_tmp = tmp_path != nil

    toml_path = Path.join([crate_path, "Cargo.toml"])

    toml_content =
      cargo_toml_content(crate.cargo_toml,
        uses_clap: Enum.any?(crate.binaries, fn binary -> binary.clap end)
      )

    delims = Kojin.CodeBlock.script_delimiters()

    Kojin.merge_generated_with_file(
      toml_content,
      toml_path,
      delims
    )

    written_toml =
      if is_using_tmp do
        tmp_toml_path = Path.join([tmp_path, "Cargo.toml"])
        File.copy!(toml_path, tmp_toml_path)
        [{tmp_toml_path, toml_path}]
      else
        []
      end

    all_modules =
      [crate.root_module] ++
        (crate.binaries
         |> Enum.map(fn binary -> binary.module end))

    generated_modules =
      all_modules
      |> Enum.map(fn module ->
        crate_generate_spec
        |> module_generate_specs(module)
        |> Enum.map(&Task.async(fn -> generate_module(&1) end))
        |> Enum.map(&Task.await/1)
        |> List.flatten()
      end)
      |> List.flatten()

    generated_files =
      (written_toml ++ generated_modules)

    # Generate the cargo
    fmt_dir = if is_using_tmp, do: tmp_path, else: crate_path

    # Format the code
    result = Porcelain.shell("cd #{fmt_dir}; cargo fmt")
    Logger.debug("`cargo fmt` on #{fmt_dir} result -> #{inspect(result)}")

    if(is_using_tmp) do
      generated_files
      |> Enum.each(fn {generated_tmp_file, original_file} ->
        new_contents = File.read!(generated_tmp_file)
        Kojin.check_write_file(original_file, new_contents)
      end)

      Logger.debug("Cleaning up tmp path #{tmp_path}")

      removed = File.rm_rf!(tmp_path)

      Logger.debug(
        "Removed formatted tmp files:\n#{inspect(removed, pretty: true, limit: :infinity)}"
      )

      :ok
    end
  end
end
