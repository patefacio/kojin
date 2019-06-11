defmodule Kojin.PodEnum do
  @moduledoc """
  Module for defining plain old data objects, independent of target language
  """

  use TypedStruct
  use Vex.Struct

  @typedoc """
  An enumeration in the C++ sense.
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:values, list(String.t()), default: [])
  end
end
