defmodule Kojin.PodObject do
  @moduledoc """
  Module for defining plain old data objects, independent of target language
  """

  use TypedStruct
  use Vex.Struct

  @typedoc """
  A plain old data object.
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:fields, list(struct()), default: [])
  end
end
