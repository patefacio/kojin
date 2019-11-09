defmodule Kojin.Pod.PodPackageSet do
  @moduledoc """
  Models a collection of related packages which may refer to
  types with `dot notation` paths.
  """

  use TypedStruct

  alias Kojin.Pod.{PodPackage, PodPackageSet, PodTypeRef}

  @typedoc """
  Models a collection of related packages which may refer to
  types with `dot notation` paths.
  """
  typedstruct enforce: true do
    field(:id, atom)
    field(:doc, binary)
    field(:packages, list(PodPackage.t()))
  end

  @doc """
  Creates a collection of related packages which may refer to
  types with `dot notation` paths.
  """
  def pod_package_set(id, doc, packages) when is_list(packages) do
    %PodPackageSet{
      id: id,
      doc: doc,
      packages: packages
    }
  end

  def find_enum(%PodPackageSet{} = pod_package_set, %PodTypeRef{} = pod_type_ref) do
    pod_package_set.packages
    |> Enum.map(fn package ->
      package.pod_enums
      |> Enum.filter(fn enum -> enum.id == pod_type_ref.type_id end)
      |> Enum.map(fn enum -> {package.path, package.id, enum} end)
    end)
    |> List.flatten()
  end

  def find_object(%PodPackageSet{} = pod_package_set, %PodTypeRef{} = pod_type_ref) do
    pod_package_set.packages
    |> Enum.map(fn package ->
      package.pod_objects
      |> Enum.filter(fn object -> object.id == pod_type_ref.type_id end)
      |> Enum.map(fn object -> {package.path, package.id, object} end)
    end)
    |> List.flatten()
  end

  def info(%PodPackageSet{} = pod_package_set) do
    IO.puts(inspect(pod_package_set, pretty: true))
  end
end
