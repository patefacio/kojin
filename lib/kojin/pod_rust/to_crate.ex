defmodule Kojin.PodRust.ToCrate do
  alias Kojin.Pod.{PodPackageSet}
  alias Kojin.Rust.{CrateGenerator, TypeAlias}
  import Kojin.PodRust.PodPackageToModule

  import Kojin.Rust.{Crate, Module}

  def to_crate(%PodPackageSet{} = pod_package_set, crate_name) when is_atom(crate_name) do
    crate(
      crate_name,
      pod_package_set.doc,
      module(:top_module, "Top module",
        type_aliases: [TypeAlias.type_alias(:date, "i32")],
        modules:
          Enum.map(pod_package_set.packages, fn pod_package ->
            to_module(pod_package_to_module(pod_package_set, pod_package))
          end)
      )
    )
  end

  def generate_crate(
        %PodPackageSet{} = pod_package_set,
        crate_name,
        target_path \\ nil
      )
      when is_atom(crate_name) do
    target_path = target_path || "/tmp/tmp/#{crate_name}"

    to_crate(pod_package_set, crate_name)
    |> CrateGenerator.generate_crate(target_path)
  end
end
