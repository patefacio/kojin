defmodule Kojin.PodField do
  @moduledoc """
  Field in a pod object
  """

  use TypedStruct
  alias Jason.{Encoder}
  alias Kojin.PodField
  # use Vex.Struct

  @derive {Encoder, only: [:name, :doc, :type, :optional?, :default_value]}

  @typedoc """
  A plain old data object.
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:type, atom | String.t(), enforce: true)
    field(:optional?, boolean(), default: false)
    field(:default_value, any())
  end

  def pod_field(name, doc, opts \\ []) do
    type = if opts[:type] == nil, do: name, else: opts[:type]
    defaults = [name: name, doc: doc, type: type]
    opts = Kojin.check_args(defaults, opts)

    PodField.__struct__(opts)
    |> validate
  end

  @spec validate(atom() | %{name: any()}) :: atom() | %{name: any()}
  def validate(pod_field) do
    Kojin.require_snake(pod_field.name)
    pod_field
  end

  def from_json(json) do
    struct(
      PodField,
      Jason.decode!(json)
      |> Enum.reduce(
        %{},
        fn {k, v}, acc -> Map.put(acc, String.to_atom(k), v) end
      )
    )
  end
end

defimpl String.Chars, for: Kojin.PodField do
  def to_string(field), do: Jason.encode!(field, pretty: true)
end
