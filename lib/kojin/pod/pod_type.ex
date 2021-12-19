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
    field(:package, binary | nil)
  end

  @doc """
  Creates `Kojin.Pod.PodType` from `id`, `doc` and
  `options`.

  - `variable_size?` Annotation indicating the object is not fixed size
  - `item_type` For arrays, the type of items in the array

  ## Examples

      iex> t = Kojin.Pod.PodType.pod_type(:number, "A number")
      ...> (%Kojin.Pod.PodType{id: :number, doc: "A number"} = t) && :match
      :match

    Id must be snake case

      iex> _t = Kojin.Pod.PodType.pod_type(:SomeNumber, "A number")
      ** (RuntimeError) PodType id `SomeNumber` must be snake case.

  """
  def pod_type(id, doc, opts \\ []) when is_atom(id) and is_binary(doc) do
    if !is_snake(id), do: raise("PodType id `#{id}` must be snake case.")

    defaults = [variable_size?: false, package: nil]
    opts = Keyword.merge(defaults, opts)

    %PodType{
      id: id,
      doc: doc,
      variable_size?: opts[:variable_size?],
      package: opts[:package]
    }
  end
end

defmodule Kojin.Pod.PodTypeRef do
  @moduledoc """
  Models a reference to a non-standard `Kojin.Pod.PodType` defined
  in a `Kojin.Pod.PodPackage`. The purpose is to decouple the definition
  of the type from its identity. Types are identified by `dot` qualified
  names:

  # Examples

  - `"package.subpackage.user_defined_type"` Refers to type `:user_defined_type` in
  package `[ :package, :subpackage ]`

  - `"root.user_defined_type"` Refers to type `:user_defined_type` in package
  `[ :root ]`

  - `:user_defined_type` Refers to type `:user_defined_type` in the _empty package_ `[]`,
  where _empty package_ implies current package.

  """
  use TypedStruct

  alias Kojin.Pod.PodTypeRef

  typedstruct enforce: true do
    field(:type_id, atom)
    field(:type_path, list(atom))
  end

  @doc """
  Create a `Kojin.Pod.PodTypeRef` from a *snake case* `dot` qualified name.

  ## Examples

     iex> alias Kojin.Pod.PodTypeRef
     ...> PodTypeRef.pod_type_ref("root.grandparent.parent.child_type")
     alias Kojin.Pod.PodTypeRef
     %PodTypeRef{
       type_id: :child_type,
       type_path: [ :root, :grandparent, :parent ]
     }

     iex> alias Kojin.Pod.PodTypeRef
     ...> PodTypeRef.pod_type_ref(:some_type)
     alias Kojin.Pod.PodTypeRef
     %PodTypeRef{
       type_id: :some_type,
       type_path: []
     }
  """
  def pod_type_ref(qualified_name) when is_binary(qualified_name) do
    parts = String.split(qualified_name, ".")

    if(Enum.any?(parts, fn part -> !is_snake(part) end)) do
      raise("PodTypeRef qualified name `#{qualified_name}` must be snake case.")
    end

    %PodTypeRef{
      type_id: String.to_atom(List.last(parts)),
      type_path:
        Enum.map(Enum.slice(parts, 0, Enum.count(parts) - 1), fn part -> String.to_atom(part) end)
    }
  end

  def pod_type_ref(name) when is_atom(name) do
    %PodTypeRef{
      type_id: name,
      type_path: []
    }
  end
end

defmodule Kojin.Pod.PodTypes do
  @moduledoc """
  Provides a set of predefined types.
  """
  import Kojin.Pod.PodType
  import Kojin.Pod.PodTypeRef

  @std_types %{
    string: pod_type(:string, "One or more characters", variable_size?: true, package: :std),
    int64: pod_type(:int64, "64 bit integer", package: :std),
    int32: pod_type(:int32, "32 bit integer", package: :std),
    int16: pod_type(:int16, "16 bit integer", package: :std),
    int8: pod_type(:int8, "64 bit integer", package: :std),
    uint64: pod_type(:uint64, "64 bit unsigned integer", package: :std),
    uint32: pod_type(:uint32, "32 bit unsigned integer", package: :std),
    uint16: pod_type(:uint16, "16 bit unsigned integer", package: :std),
    uint8: pod_type(:uint8, "8 bit unsigned integer", package: :std),
    char: pod_type(:char, "Single ASCII character", package: :std),
    uchar: pod_type(:uchar, "Single ASCII unsigned character", package: :std),
    date: pod_type(:date, "A date", package: :std),
    timestamp:
      pod_type(:timestamp, "A timestamp that includes both date and time", package: :std),
    double: pod_type(:double, "64-bit floating point number", package: :std),
    boolean: pod_type(:boolean, "A boolean (true/false) value", package: :std),
    uuid: pod_type(:boolean, "A boolean (true/false) value", package: :std)
  }

  @example_tests @std_types
                 |> Enum.map(fn {_name, type} ->
                   """
                       iex> Kojin.Pod.PodTypes.pod_type(:#{type.id})
                       #{inspect(type)}
                   """
                 end)

  @doc """
  Return the std type identified by the provided atom.

  ## Examples

  #{@example_tests}
  }

      iex> Kojin.Pod.PodTypes.pod_type(:user_defined_type)
      %Kojin.Pod.PodTypeRef{
        type_id: :user_defined_type,
        type_path: []
      }

  """
  def pod_type(%Kojin.Pod.PodType{} = pod_type), do: pod_type
  def pod_type(%Kojin.Pod.PodTypeRef{} = pod_type_ref), do: pod_type_ref
  def pod_type(%Kojin.Pod.PodArray{} = pod_array), do: pod_array
  def pod_type(%Kojin.Pod.PodMap{} = pod_map), do: pod_map
  def pod_type(:string), do: @std_types.string
  def pod_type(:int64), do: @std_types.int64
  def pod_type(:int32), do: @std_types.int32
  def pod_type(:int16), do: @std_types.int16
  def pod_type(:int8), do: @std_types.int8
  def pod_type(:uint64), do: @std_types.uint64
  def pod_type(:uint32), do: @std_types.uint32
  def pod_type(:uint16), do: @std_types.uint16
  def pod_type(:uint8), do: @std_types.uint8
  def pod_type(:char), do: @std_types.char
  def pod_type(:uchar), do: @std_types.uchar
  def pod_type(:date), do: @std_types.date
  def pod_type(:timestamp), do: @std_types.timestamp
  def pod_type(:double), do: @std_types.double
  def pod_type(:boolean), do: @std_types.boolean
  def pod_type(:uuid), do: @std_types.uuid
  def pod_type(t) when is_atom(t), do: pod_type_ref(t)
  def pod_type(t) when is_binary(t), do: pod_type_ref(t)

  @doc """
  Map of std types indexed by atom
  """
  def std(), do: @std_types

  @doc """

  Returns a referred to type (e.g. user defined type)

  """
  def ref_type(%Kojin.Pod.PodType{} = _pod_type), do: nil
  def ref_type(%Kojin.Pod.PodTypeRef{} = pod_type_ref), do: pod_type_ref
  def ref_type(%Kojin.Pod.PodArray{} = pod_array), do: ref_type(pod_array.item_type)
  def ref_type(%Kojin.Pod.PodMap{} = pod_map), do: ref_type(pod_map.value_type)

  def is_pod_map?(%Kojin.Pod.PodMap{} = _), do: true
  def is_pod_map?(_), do: false

  def is_pod_array?(%Kojin.Pod.PodArray{} = _), do: true
  def is_pod_array?(_), do: false
end
