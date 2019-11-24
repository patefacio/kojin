defmodule Kojin.Pod.PodPackageSet do
  @moduledoc """
  Models a collection of related packages which may refer to
  types with `dot notation` paths.
  """

  use TypedStruct

  alias Kojin.Pod.{PodPackage, PodPackageSet, PodTypeRef, PodArray, PodType, PodObject, PodEnum}

  @typedoc """
  Models a collection of related packages which may refer to
  types with `dot notation` paths.
  """
  typedstruct enforce: true do
    field(:id, atom)
    field(:doc, binary)
    field(:packages, list(PodPackage.t()))
    field(:enums, list(PodEnum.t()))
    field(:enums_map, %{atom => list(PodEnum.t())})
    field(:objects, list(PodObject.t()))
    field(:objects_map, %{atom => list(PodObject.t())})
  end

  @doc """
  Creates a collection of related packages which may refer to
  types with `dot notation` paths.
  """
  def pod_package_set(id, doc, packages) when is_list(packages) do
    enums =
      packages
      |> Enum.map(fn package -> Enum.map(package.pod_enums, fn e -> {package.id, e} end) end)
      |> List.flatten()

    objects =
      packages
      |> Enum.map(fn package -> Enum.map(package.pod_objects, fn o -> {package.id, o} end) end)
      |> List.flatten()

    %PodPackageSet{
      id: id,
      doc: doc,
      packages: packages,
      enums: enums,
      enums_map: Enum.group_by(enums, fn {_pkg, e} -> e.id end),
      objects: objects,
      objects_map: Enum.group_by(objects, fn {_pkg, o} -> o.id end)
    }
  end

  def find_item_id(%PodPackageSet{} = pod_package_set, id) when is_atom(id) do
    Enum.find(pod_package_set.enums_map, fn {e_id, _list} -> e_id == id end) ||
      Enum.find(pod_package_set.objects_map, fn {o_id, _list} -> o_id == id end)
  end

  def find_pod_package(%PodPackageSet{} = pod_package_set, package_id) when is_atom(package_id) do
    pod_package_set.packages
    |> Enum.find(fn package -> package.id == package_id end)
  end

  def find_object(%PodPackageSet{} = pod_package_set, %PodTypeRef{} = pod_type_ref) do
    pod_package_set.packages
    |> Enum.find_value(fn package -> PodPackage.find_object(package, pod_type_ref) end)
  end

  def find_enum(%PodPackageSet{} = pod_package_set, %PodTypeRef{} = pod_type_ref) do
    pod_package_set.packages
    |> Enum.find_value(fn package -> PodPackage.find_enum(package, pod_type_ref) end)
  end

  def all_types(%PodPackageSet{} = pod_package_set) do
    pod_package_set.packages
    |> Enum.reduce(MapSet.new(), fn pod_package, acc ->
      MapSet.union(acc, PodPackage.all_types(pod_package))
    end)
  end

  def all_pod_types(%PodPackageSet{} = pod_package_set) do
    for {_package, %PodType{}} = elm <- all_types(pod_package_set), do: elm
  end

  def all_ref_types(%PodPackageSet{} = pod_package_set) do
    for {_package, %PodTypeRef{}} = elm <- all_types(pod_package_set), do: elm
  end

  def all_array_types(%PodPackageSet{} = pod_package_set) do
    for {_package, %PodArray{}} = elm <- all_types(pod_package_set), do: elm
  end

  def info(%PodPackageSet{} = pod_package_set) do
    IO.puts(inspect(pod_package_set, pretty: true))
  end
end
