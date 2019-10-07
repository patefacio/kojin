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

  @doc """
  Returns value if given `Kojin.Pod.PodField`.
  """
  @spec pod_field(Kojin.Pod.PodField.t()) :: Kojin.Pod.PodField.t()
  def pod_field(%PodField{} = pod_field), do: pod_field

  @doc """
  Creates a `Kojin.Pod.PodField` if provided list that looks like field parameters.

  ## Examples

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

  """
  def pod_field([id, doc, type]), do: pod_field(id, doc, type)

  @doc """
  Creates a `Kojin.Pod.PodField` if provided list that looks like field parameters.

  ## Examples

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

  """
  def pod_field([id, doc]), do: pod_field(id, doc)

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

  @doc """
  Creates a `Kojin.PodField` from the provide `name`, `doc`
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

  """
  def pod_field(id, doc, type)
      when is_atom(id) and is_binary(doc) and is_atom(type) do
    pod_field(id, doc, type: PodTypes.pod_type(type))
  end
end

defimpl String.Chars, for: Kojin.PodField do
  def to_string(field), do: Jason.encode!(field, pretty: true)
end
