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

  alias Kojin.Rust.{ModuleFile, GeneratedRustModule}

  typedstruct do
    field(:original_module_file, Kojin.Rust.ModuleFile.t(), enforce: true)
    field(:generated_content, String.t(), enforce: true)
  end

  def generated_rust_module(path, generated_content) do
    {file_stat, content} =
      if(File.exists?(path)) do
        {File.stat!(path), File.read!(path)}
      else
        {nil, nil}
      end

    %GeneratedRustModule{
      original_module_file: %ModuleFile{
        path: path,
        file_stat: file_stat,
        content: content
      },
      generated_content: generated_content
    }
  end

  def write_contents(generated_rust_module) do
    path = generated_rust_module.original_module_file.path
    parent = Path.dirname(path)

    if(!File.exists?(parent)) do
      File.mkdir_p!(parent)
    end

    File.write!(
      path,
      generated_rust_module.generated_content
    )
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
