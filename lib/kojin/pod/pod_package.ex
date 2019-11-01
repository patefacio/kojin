import Kojin.Id

defmodule Kojin.Pod.PodPackage do
  @moduledoc """
  Models a package of related `Kojin.Pod.PodObject` and
  `Kojin.Pod.PodEnum` instances
  """

  use TypedStruct

  alias Kojin.Pod.PodPackage

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
    field(:path, binary)
  end

  @doc """
  Creates a `Kojin.Pod.PodPackage` of related `Kojin.Pod.PodObject` and
  `Kojin.Pod.PodEnum` instances.

  ## Examples

      iex> import Kojin.Pod.{PodPackage, PodEnum, PodObject}
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
        pod_enums: [],
        pod_objects: [
          %Kojin.Pod.PodObject{
            doc: "A 2 dimensional point",
            fields: [
              %Kojin.Pod.PodField{
                default_value: nil,
                doc: "Abcissa",
                id: :x,
                optional?: false,
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
        path: nil
      }


  """
  def pod_package(id, doc, opts \\ []) when is_atom(id) and is_binary(doc) do
    if !is_snake(id), do: raise("PodPackage id `#{id}` must be snake case.")

    defaults = [
      pod_enums: [],
      pod_objects: [],
      imports: [],
      path: nil
    ]

    opts = Kojin.check_args(defaults, opts)

    %PodPackage{
      id: id,
      doc: doc,
      pod_enums: opts[:pod_enums],
      pod_objects: opts[:pod_objects],
      imports: opts[:imports],
      path: opts[:path]
    }
  end
end
