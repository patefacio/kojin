import Kojin.Id

defmodule Kojin.Pod.PodType do
  @moduledoc """
  A set of functions for defining _Plain Old Data_ types (i.e. POD Types).
  """

  alias Kojin.Pod.PodType
  use TypedStruct

  @typedoc """
  A `Kojin.Pod.PodType` defines a type that can be used to type fields
  in objects and arrays in a schema.

  - `id`: The identifier for the _POD_ type.
  - `doc`: Documentation for the type
  - `variable_size?`: Boolean indicating if type is _fixed size_, for purposes
    of serialization
  - `item_type`: Used only for array types to refer to the type of items in
    the array.
  """
  typedstruct enforce: true do
    field(:id, atom)
    field(:doc, binary)
    field(:variable_size?, boolean)
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

    Id must be snake case

      iex> t = Kojin.Pod.PodType.pod_type(:SomeNumber, "A number")
      ** (RuntimeError) PodType id `SomeNumber` must be snake case.

  """
  def pod_type(id, doc, opts \\ []) when is_atom(id) and is_binary(doc) do
    if !is_snake(id), do: raise("PodType id `#{id}` must be snake case.")

    defaults = [variable_size?: false]
    opts = Keyword.merge(opts, defaults)

    %PodType{
      id: id,
      doc: doc,
      variable_size?: opts[:variable_size?]
    }
  end
end

defmodule Kojin.Pod.PodTypes do
  @moduledoc """
  Provides a set of predefined types.
  """
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
