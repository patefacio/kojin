defmodule Kojin.Rust.ModuleFile do
  use TypedStruct

  typedstruct do
    field(:path, String.t(), enforce: true)
    field(:file_stat, File.Stat.t(), enforce: true)
    field(:content, String.t(), enforce: true)
  end
end

defmodule Kojin.Rust.GeneratedRustModule do
  use TypedStruct

  import Kojin.Utils
  alias Kojin.Rust.{ModuleFile, GeneratedRustModule}

  typedstruct do
    field(:original_module_file, Kojin.Rust.ModuleFile.t(), enforce: true)
  end

  def generated_rust_module(path, generated_content) do
    parent = Path.dirname(path)

    if(!File.exists?(parent)) do
      File.mkdir_p!(parent)
    end

    {file_stat, content} =
      if(File.exists?(path)) do
        {File.stat!(path), File.read!(path)}
      else
        {nil, nil}
      end

    File.write!(path, generated_content)

    %GeneratedRustModule{
      original_module_file: %ModuleFile{
        path: path,
        file_stat: file_stat,
        content: content
      }
    }
  end

  def evaluate_formatted_diff(generated_rust_module) do
    original_module_file = generated_rust_module.original_module_file
    path = original_module_file.path
    file_stat = original_module_file.file_stat

    if(!File.exists?(path)) do
      {:wrote_new, path, nil}
    else
      contents = File.read!(path)

      if(contents == original_module_file.content) do
        File.write_stat!(path, file_stat)
        {:no_change, path, file_stat}
      else
        {:updated, path, nil}
      end
    end
  end
end

defmodule Kojin.Rust.GeneratedResults do
  use TypedStruct

  typedstruct do
    field(:generated_rust_modules, map())
  end
end

defmodule Kojin.Rust.GenerateSpec do
  use TypedStruct
  alias Kojin.Rust.Module

  typedstruct do
    field(:path, String.t(), enforce: true)
    field(:parent, Module.t(), default: nil)
  end
end
