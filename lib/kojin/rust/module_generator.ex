defmodule Kojin.Rust.ModuleGenerateSpec do
  use TypedStruct
  alias Kojin.Rust.{Module, CrateGenerateSpec, ModuleGenerateSpec}

  typedstruct enforce: true do
    field(:crate_generate_spec, CrateGenerateSpec.t())
    field(:parent_module_generate_spec, CrateGenerateSpec.t())
    field(:module, Module.t(), default: nil)
    field(:module_relative_path, String.t())
  end

  def module_generate_spec(
        %CrateGenerateSpec{} = crate_generate_spec,
        %Module{} = module,
        parent_module_generate_spec \\ nil
      ) do
    module_relative_path =
      if(parent_module_generate_spec) do
        parent_dir = Path.dirname(parent_module_generate_spec.module_relative_path)

        case module.type do
          :file ->
            Path.join([parent_dir, "#{module.file_name}"])

          :directory ->
            mod_dir = Path.join([parent_dir, "#{module.name}"])
            fully_qualified = CrateGenerateSpec.absolute_target_path(crate_generate_spec, mod_dir)
            File.mkdir_p!(fully_qualified)
            Path.join([mod_dir, "mod.rs"])

          :inline ->
            Path.join([parent_dir, "#{module.name}", "inline"])
        end
      else
        "src/lib.rs"
      end

    %ModuleGenerateSpec{
      crate_generate_spec: crate_generate_spec,
      parent_module_generate_spec: parent_module_generate_spec,
      module: module,
      module_relative_path: module_relative_path
    }
  end
end

defmodule Kojin.Rust.ModuleGenerator do
  require Logger
  alias Kojin.Rust.{Module, ModuleGenerateSpec}

  @spec generate_module(ModuleGenerateSpec.t()) :: any
  def generate_module(%ModuleGenerateSpec{} = module_generate_spec) do
    module = module_generate_spec.module
    crate_generate_spec = module_generate_spec.crate_generate_spec

    written =
      if(module.type != :inline) do
        %{crate_path: crate_path, tmp_path: tmp_path} = crate_generate_spec
        is_using_tmp = tmp_path != nil

        original_path = Path.join([crate_path, module_generate_spec.module_relative_path])

        {original_content, content} =
          if(File.exists?(original_path)) do
            original_content = File.read!(original_path)
            {original_content, Kojin.merge(Module.content(module), original_content)}
          else
            {nil, Module.content(module)}
          end

        if(is_using_tmp) do
          target_path =
            Path.join([crate_generate_spec.tmp_path, module_generate_spec.module_relative_path])

          dirname = Path.dirname(target_path)

          if !File.exists?(dirname) do
            File.mkdir_p!(dirname)
          end

          File.write!(target_path, content)
          {target_path, original_path}
        else
          Kojin.check_write_file(original_path, content, original_content)
          nil
        end

        # Logger.info("Generating module `#{module.name}` -> #{inspect(written)}")
      end

    submodules =
      module.modules
      |> Enum.reduce([], fn submodule, acc ->
        [
          ModuleGenerateSpec.module_generate_spec(
            crate_generate_spec,
            submodule,
            module_generate_spec
          )
          |> generate_module()
          | acc
        ]
      end)

    if(written != nil) do
      [written | submodules]
    else
      []
    end
  end
end
