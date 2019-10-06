import Kojin.Id

defmodule Kojin.Pod.EnumValue do
  use TypedStruct

  typedstruct enforce: true do
    field(:id, atom)
    field(:doc, binary | nil)
  end

  @doc """
  Creates an `Kojin.Pod.EnumValue` from `id` and `doc`.

  ## Examples

      iex> Kojin.Pod.EnumValue.ev(:red)
      %Kojin.Pod.EnumValue{ id: :red, doc: nil }

      iex> Kojin.Pod.EnumValue.ev(:red, "The color of blood")
      %Kojin.Pod.EnumValue{ id: :red, doc: "The color of blood" }      

    Id must be snake case

      iex> Kojin.Pod.EnumValue.ev(:Foo)
      ** (RuntimeError) Enum value id `Foo` must be snake case.

  """
  @spec ev(atom, binary | nil) :: Kojin.Pod.EnumValue.t() | none
  def ev(id, doc) when is_atom(id) do
    if !is_snake(id), do: raise("Enum value id `#{id}` must be snake case.")

    %Kojin.Pod.EnumValue{
      id: id,
      doc: doc
    }
  end

  def ev(id, nil) when is_atom(id), do: ev(id, nil)

  def ev(id) when is_atom(id), do: ev(id, nil)

  def ev(%Kojin.Pod.EnumValue{} = ev), do: ev

  defmodule String.Chars do
    def to_string(%Kojin.Pod.EnumValue{} = ev) do
      "#{ev.id}"
    end
  end
end

defmodule Kojin.Pod.PodEnum do
  @moduledoc """
  Module for defining plain old data objects, independent of target language
  """

  use TypedStruct

  @typedoc """
  An enumeration in the C++ sense.
  """
  typedstruct enforce: true do
    field(:id, atom, enforce: true)
    field(:doc, String.t())
    field(:values, list(Kojin.Pod.EnumValue), default: [])
  end

  @doc ~S"""
  Create a `Kojin.Pod.PodEnum` from the `id` (snake case),
  `doc` comment and list of enum values.


  ## Examples

      iex> Kojin.Pod.PodEnum.pod_enum(:color, "Fundamental colors", [:red, :green, :blue])
      alias Kojin.Pod.{PodEnum, EnumValue}
      %PodEnum{ id: :color, doc: "Fundamental colors", values: [
        %EnumValue{id: :red, doc: nil}, 
        %EnumValue{id: :green, doc: nil}, 
        %EnumValue{id: :blue, doc: nil}
        ] 
      }

      iex> Kojin.Pod.PodEnum.pod_enum(:TheColor, "Fundamental colors", [:red, :green, :blue])
      ** (RuntimeError) Enum id `TheColor` must be snake case.

  """
  @spec pod_enum(atom, binary, any) :: Kojin.Pod.PodEnum.t()
  def pod_enum(id, doc, values) when is_atom(id) and is_binary(doc) do
    if !is_snake(id), do: raise("Enum id `#{id}` must be snake case.")

    %Kojin.Pod.PodEnum{
      id: id,
      doc: doc,
      values: Enum.map(values, fn ev -> Kojin.Pod.EnumValue.ev(ev) end)
    }
  end
end
