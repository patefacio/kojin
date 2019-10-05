defmodule Kojin.Pod.PodField do
  @moduledoc """
  Field in a pod object
  """

  use TypedStruct
  alias Jason.{Encoder}
  alias Kojin.Pod.PodField
  # use Vex.Struct

  @derive {Encoder, only: [:id, :doc, :type, :optional?, :default_value]}

  @typedoc """
  A plain old data object.
  """
  typedstruct enforce: true do
    field(:id, atom)
    field(:doc, String.t())
    field(:type, PodType.t())
    field(:optional?, boolean(), default: false)
    field(:default_value, any())
  end

  @doc """
  Creates a `Kojin.PodField` from the provide `name`, `doc`
  and `opts`.

  ## Examples

      iex> Kojin.PodField.pod_field(:f_1, "A field")
  """
  def pod_field(id, doc, opts \\ []) do
    type = if opts[:type] == nil, do: id, else: opts[:type]
    defaults = [id: id, doc: doc, type: type, default_value: nil]
    opts = Kojin.check_args(defaults, opts)

    PodField.__struct__(opts)
    |> validate
  end

  @spec validate(atom() | %{id: any()}) :: atom() | %{id: any()}
  def validate(pod_field) do
    Kojin.require_snake(pod_field.id)
    pod_field
  end
end

defimpl String.Chars, for: Kojin.PodField do
  def to_string(field), do: Jason.encode!(field, pretty: true)
end
