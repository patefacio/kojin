defmodule Kojin.Pod.PodObject do
  @moduledoc """
  Module for defining plain old data objects, independent of target language
  """

  alias Kojin.Pod.PodField

  use TypedStruct
  use Vex.Struct

  @typedoc """
  A plain old data object.
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:fields, list(PodField.t()), default: [])
  end
end
