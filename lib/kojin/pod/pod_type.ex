defmodule Kojin.Pod.PodType do
  alias Kojin.Pod.PodType
  use TypedStruct

  typedstruct enforce: true do
    field(:id, atom)
    field(:doc, binary)
    field(:variable_size?, boolean)
    field(:item_type, Kojin.Pod.PodType.t())
  end

  @doc """
  Creates `Kojin.Pod.PodType` from `id`, `doc` and
  `options`.

  - `variable_size?` Annotation indicating the object is not fixed size
  - `item_type` For arrays, the type of items in the array

  ## Examples

      iex> t = Kojin.Pod.PodType.pod_type(:number, "A number")
      ...> (%Kojin.Pod.PodType{id: :number} = t) && :match
      :match

  """
  def pod_type(id, doc, opts \\ []) when is_atom(id) and is_binary(doc) do
    defaults = [variable_size?: false, item_type: nil]
    opts = Keyword.merge(opts, defaults)

    %PodType{
      id: id,
      doc: doc,
      variable_size?: opts[:variable_size],
      item_type: opts[:item_type]
    }
  end
end

defmodule PodTypes do
  import Kojin.Pod.PodType

  @predefined %{
    string: pod_type(:string, "One or more characters", variable_size?: true),
    int64: pod_type(:int64, "64 bit integer"),
    int32: pod_type(:int32, "32 bit integer"),
    int16: pod_type(:int16, "16 bit integer"),
    int8: pod_type(:int8, "64 bit integer"),
    uint64: pod_type(:uint64, "64 bit unsigned integer"),
    uint32: pod_type(:uint32, "32 bit unsigned integer"),
    uint16: pod_type(:uint16, "16 bit unsigned integer"),
    uint8: pod_type(:uint8, "8 bit unsigned integer"),
    char: pod_type(:char, "Single ASCII character"),
    uchar: pod_type(:uchar, "Single ASCII unsigned character"),
    date: pod_type(:date, "A date"),
    timestamp: pod_type(:timestamp, "A timestamp that includes both date and time"),
    double: pod_type(:double, "64-bit floating point number"),
    boolean: pod_type(:boolean, "A boolean (true/false) value"),
    uuid: pod_type(:boolean, "A boolean (true/false) value")
  }

  def pod_type(:string), do: @predefined.string
  def pod_type(:int64), do: @predefined.int64
  def pod_type(:int32), do: @predefined.int32
  def pod_type(:int16), do: @predefined.int16
  def pod_type(:int8), do: @predefined.int8
  def pod_type(:uint64), do: @predefined.uint64
  def pod_type(:uint32), do: @predefined.uint32
  def pod_type(:uint16), do: @predefined.uint16
  def pod_type(:uint8), do: @predefined.uint8
  def pod_type(:char), do: @predefined.char
  def pod_type(:uchar), do: @predefined.uchar
  def pod_type(:date), do: @predefined.date
  def pod_type(:timestamp), do: @predefined.timestamp
  def pod_type(:double), do: @predefined.double
  def pod_type(:boolean), do: @predefined.boolean
  def pod_type(:uuid), do: @predefined.uuid
end
