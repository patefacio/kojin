import Kojin.Id

defmodule Kojin.Pod.PodPackage do
  @moduledoc """
  Models a package of related `Kojin.Pod.PodObject` and
  `Kojin.Pod.PodEnum` instances
  """

  use TypedStruct

  alias Kojin.Pod.{PodPackage, PodTypeRef, PodObject, PodEnum}

  @typedoc """
  Models a package of related `Kojin.Pod.PodObject` and
  `Kojin.Pod.PodEnum` instances
  """
  typedstruct enforce: true do
    field(:id, atom)
    field(:doc, binary)
    field(:pod_enums, list(PodEnum.t()))
    field(:pod_objects, list(PodObject.t()))
    field(:imports, list(binary))
    field(:pod_packages, list(PodPackage.t()))
    field(:path, binary)
    field(:pod_enums_map, %{atom => PodEnum.t()})
    field(:pod_objects_map, %{atom => PodObject.t()})
  end

  @doc """
  Creates a `Kojin.Pod.PodPackage` of related `Kojin.Pod.PodObject` and
  `Kojin.Pod.PodEnum` instances.

  ## Examples

      iex> import Kojin.Pod.{PodPackage, PodObject}
      ...> pod_package(:p,
      ...>   "The `P` package",
      ...>   pod_objects: [
      ...>      pod_object(:point, "A 2 dimensional point", [
      ...>         [:x, "Abcissa", :int32],
      ...>         [:y, "Ordinate", :int32]
      ...>      ])
      ...>  ])
      %Kojin.Pod.PodPackage{
              doc: "The `P` package",
              id: :p,
              imports: [],
              path: nil,
              pod_enums: [],
              pod_enums_map: %{},
              pod_objects: [
                %Kojin.Pod.PodObject{
                  doc: "A 2 dimensional point",
                  fields: [
                    %Kojin.Pod.PodField{
                      default_value: nil,
                      doc: "Abcissa",
                      id: :x,
                      optional?: false,
                      properties: %{},
                      type: %Kojin.Pod.PodType{
                        doc: "32 bit integer",
                        id: :int32,
                        package: :std,
                        variable_size?: false
                      }
                    },
                    %Kojin.Pod.PodField{
                      default_value: nil,
                      doc: "Ordinate",
                      id: :y,
                      optional?: false,
                      properties: %{},
                      type: %Kojin.Pod.PodType{
                        doc: "32 bit integer",
                        id: :int32,
                        package: :std,
                        variable_size?: false
                      }
                    }
                  ],
                  id: :point
                }
              ],
              pod_objects_map: %{
                point: %Kojin.Pod.PodObject{
                  doc: "A 2 dimensional point",
                  fields: [
                    %Kojin.Pod.PodField{
                      default_value: nil,
                      doc: "Abcissa",
                      id: :x,
                      optional?: false,
                      properties: %{},
                      type: %Kojin.Pod.PodType{
                        doc: "32 bit integer",
                        id: :int32,
                        package: :std,
                        variable_size?: false
                      }
                    },
                    %Kojin.Pod.PodField{
                      default_value: nil,
                      doc: "Ordinate",
                      id: :y,
                      optional?: false,
                      properties: %{},
                      type: %Kojin.Pod.PodType{
                        doc: "32 bit integer",
                        id: :int32,
                        package: :std,
                        variable_size?: false
                      }
                    }
                  ],
                  id: :point
                }
              },
              pod_packages: []
            }
  """
  def pod_package(id, doc, opts \\ []) when is_atom(id) and is_binary(doc) do
    if !is_snake(id), do: raise("PodPackage id `#{id}` must be snake case.")

    defaults = [
      pod_enums: [],
      pod_objects: [],
      imports: [],
      pod_packages: [],
      path: nil
    ]

    opts = Kojin.check_args(defaults, opts)

    enums = opts[:pod_enums]
    enums_map = enums |> Enum.map(fn e -> {e.id, e} end) |> Map.new()

    objects = opts[:pod_objects]
    objects_map = objects |> Enum.map(fn o -> {o.id, o} end) |> Map.new()

    %PodPackage{
      id: id,
      doc: doc,
      pod_enums: enums,
      pod_objects: objects,
      imports: opts[:imports],
      pod_packages: opts[:pod_packages],
      path: opts[:path],
      pod_enums_map: enums_map,
      pod_objects_map: objects_map
    }
  end

  def find_object(%PodPackage{} = pod_package, %PodTypeRef{} = pod_type_ref) do
    found = Map.get(pod_package.pod_objects_map, pod_type_ref.type_id)

    if found do
      {pod_package.id, found}
    end
  end

  def find_enum(%PodPackage{} = pod_package, %PodTypeRef{} = pod_type_ref) do
    found = Map.get(pod_package.pod_enums_map, pod_type_ref.type_id)

    if found do
      {pod_package.id, found}
    end
  end

  @doc """
  Returns the set of all types within the package.
  """
  def all_types(%PodPackage{} = pod_package) do
    pod_package.pod_objects
    |> Enum.reduce(MapSet.new(), fn pod_object, acc ->
      MapSet.union(
        acc,
        PodObject.all_types(pod_object)
        |> Enum.map(fn t -> {pod_package.id, t} end)
        |> MapSet.new()
      )
    end)
  end

  @doc """
  Returns the set of all reference types within the package.
  """
  def all_ref_types(%PodPackage{} = pod_package) do
    pod_package.pod_objects
    |> Enum.reduce(MapSet.new(), fn pod_object, acc ->
      MapSet.union(
        acc,
        PodObject.all_ref_types(pod_object)
        |> Enum.map(fn t -> t end)
        |> MapSet.new()
      )
    end)
  end

  @spec all_field_types(PodPackage.t()) :: list(PodPackage.t())
  def all_field_types(%PodPackage{} = pod_package) do
    pod_package.pod_objects
    |> Enum.reduce(MapSet.new(), fn pod_object, acc ->
      MapSet.union(
        acc,
        pod_object.fields
        |> Enum.map(fn field -> field.type end)
        |> MapSet.new()
      )
    end)
  end
end
