import Kojin.Id

defmodule Kojin.Pod.PodField do
  @moduledoc """
  Field in a pod object
  """

  use TypedStruct
  alias Kojin.Pod.{PodField, PodTypes}
  # use Vex.Struct

  @typedoc """
  A plain old data object.
  """
  typedstruct enforce: true do
    field(:id, atom)
    field(:doc, String.t())
    field(:type, PodType.t())
    field(:optional?, boolean())
    field(:default_value, any())
  end

  def pod_field(%PodField{} = pod_field), do: pod_field

  def pod_field(id, doc, opts \\ [])

  @doc """
  Creates a `Kojin.PodField` from the provide `name`, `doc`
  and `opts`.

  ## Examples

      iex> Kojin.Pod.PodField.pod_field(:f_1, "A field")
      import Kojin.Pod.PodTypes
      %Kojin.Pod.PodField{id: :f_1,
        doc: "A field",
        type: pod_type(:string),
        default_value: nil,
        optional?: false
      }

  """
  def pod_field(id, doc, opts) when is_atom(id) and is_binary(doc) and is_list(opts) do
    if !is_snake(id), do: raise("PodField id `#{id}` must be snake case.")

    defaults = [
      id: id,
      doc: doc,
      type: Keyword.get(opts, :type, PodTypes.pod_type(:string)),
      default_value: nil,
      optional?: false
    ]

    opts = Kojin.check_args(defaults, opts)

    %PodField{
      id: id,
      doc: doc,
      type: opts[:type],
      optional?: opts[:optional?],
      default_value: opts[:default_value]
    }
  end

  def pod_field([id, doc, type]), do: pod_field(id, doc, type)

  def pod_field(id, doc, type)
      when is_atom(id) and is_binary(doc) and is_atom(type) do
    pod_field(id, doc, type: PodTypes.pod_type(type))
  end
end

defimpl String.Chars, for: Kojin.PodField do
  def to_string(field), do: Jason.encode!(field, pretty: true)
end
