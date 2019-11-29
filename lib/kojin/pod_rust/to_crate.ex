defmodule Kojin.PodRust.ToCrate do
  alias Kojin.Pod.{PodPackageSet, PodTypes}
  alias Kojin.Rust.{CrateGenerator}
  import Kojin.PodRust.PodPackageToModule

  import Kojin.Rust.{Crate, Module}

  def to_crate(%PodPackageSet{} = pod_package_set, crate_name) when is_atom(crate_name) do
    date_type = PodTypes.pod_type(:date)

    uses_date =
      PodPackageSet.all_types(pod_package_set)
      |> Enum.any?(fn {_pkg, t} -> t == date_type end)

    crate(
      crate_name,
      pod_package_set.doc,
      module(:top_module, "Top module",
        modules:
          Enum.map(pod_package_set.packages, fn pod_package ->
            to_module(pod_package_to_module(pod_package_set, pod_package))
          end)
      ),
      dependencies:
        [
          ~s(serde = "^1.0.103"),
          ~s(serde_derive = "^1.0.103")
        ] ++
          if(uses_date) do
            [~s(chrono = { version = "0.4.10", features = ["serde"] })]
          else
            []
          end
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
