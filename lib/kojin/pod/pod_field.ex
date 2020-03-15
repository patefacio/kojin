import Kojin.Id

defmodule Kojin.Pod.PodField do
  @moduledoc """
  Field in a pod object
  """

  use TypedStruct
  alias Kojin.Pod.{PodField, PodType, PodArray, PodMap, PodTypeRef, PodTypes}

  # use Vex.Struct

  @typedoc """
  A plain old data object.
  """
  typedstruct enforce: true do
    field(:id, atom)
    field(:doc, String.t())
    field(:type, PodType.t() | PodTypeRef.t() | PodArray.t() | PodMap.t())
    field(:optional?, boolean())
    field(:default_value, any())
  end

  @doc """
  Creates a `Kojin.Pod.PodField` if provided list that looks like field parameters.

  ## Examples

    When provided list [id, doc, atom type] that looks like field parameters.

      iex> import Kojin.Pod.{PodField}
      ...> pod_field([:f_1, "A field", :int32])
      alias Kojin.Pod.PodField
      import Kojin.Pod.PodTypes
      %PodField{
        id: :f_1,
        doc: "A field",
        type: pod_type(:int32),
        default_value: nil,
        optional?: false
      }

    When provided list [id, doc] that looks like field parameters, defaulting to string.

      iex> import Kojin.Pod.{PodField}
      ...> pod_field([:f_1, "A field"])
      alias Kojin.Pod.PodField
      import Kojin.Pod.PodTypes
      %PodField{
        id: :f_1,
        doc: "A field",
        type: pod_type(:string),
        default_value: nil,
        optional?: false
      }

    When provided list [id, doc, array of type] that looks like field parameters.

      iex> import Kojin.Pod.{PodField, PodArray}
      ...> pod_field([:f_1, "Int array", array_of(:int32)])
      alias Kojin.Pod.PodField
      import Kojin.Pod.{PodTypes, PodArray}
      %PodField{
        id: :f_1,
        doc: "Int array",
        type: array_of(:int32),
        default_value: nil,
        optional?: false
      }

  """
  @spec pod_field(Kojin.Pod.PodField.t()) :: Kojin.Pod.PodField.t()
  def pod_field(%PodField{} = pod_field), do: pod_field

  def pod_field([id, doc, type]), do: pod_field(id, doc, type)

  def pod_field([id, doc, type, opts]), do: pod_field(id, doc, Keyword.merge(opts, type: type))

  def pod_field([id, doc]), do: pod_field(id, doc)

  @doc """
  Creates a `Kojin.PodField` from the provided `name`, `doc`
  and predefined type identified by `type` atom.

  ## Examples

      iex> Kojin.Pod.PodField.pod_field(:f_1, "A field", :int64)
      import Kojin.Pod.PodTypes
      %Kojin.Pod.PodField{id: :f_1,
        doc: "A field",
        type: pod_type(:int64),
        default_value: nil,
        optional?: false
      }

      iex> Kojin.Pod.PodField.pod_field(:f_1, "A field")
      import Kojin.Pod.PodTypes
      %Kojin.Pod.PodField{id: :f_1,
        doc: "A field",
        type: pod_type(:string),
        default_value: nil,
        optional?: false
      }

  """
  def pod_field(id, doc, opts \\ [])

  def pod_field(id, doc, opts) when is_atom(id) and is_binary(doc) and is_list(opts) do
    if !is_snake(id), do: raise("PodField id `#{id}` must be snake case.")

    defaults = [
      id: id,
      doc: doc,
      type: :string,
      default_value: nil,
      optional?: false
    ]

    opts = Kojin.check_args(defaults, opts)

    %PodField{
      id: id,
      doc: doc,
      type: PodTypes.pod_type(opts[:type]),
      optional?: opts[:optional?],
      default_value: opts[:default_value]
    }
  end

  def pod_field(id, doc, type)
      when is_atom(id) and is_binary(doc) and is_atom(type) do
    pod_field(id, doc, type: PodTypes.pod_type(type))
  end

  def pod_field(id, doc, %PodType{} = type), do: pod_field(id, doc, type: type)
  def pod_field(id, doc, %PodTypeRef{} = type), do: pod_field(id, doc, type: type)
  def pod_field(id, doc, %PodArray{} = type), do: pod_field(id, doc, type: type)
  def pod_field(id, doc, %PodMap{} = type), do: pod_field(id, doc, type: type)
end

defimpl String.Chars, for: Kojin.PodField do
  def to_string(field), do: Jason.encode!(field, pretty: true)
end
