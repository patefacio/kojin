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

  typedstruct do
    field(:original_module_file, Kojin.Rust.ModuleFile.t(), enforce: true)
    field(:generated_content, String.t(), enforce: true)
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
