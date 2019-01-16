defmodule Kojin.Rust.Struct do
  @moduledoc """
  Rust _struct_ definition.
  """

  alias Kojin.Rust.Field
  alias Kojin.Rust.Struct
  use TypedStruct
  use Vex.Struct

  @typedoc """
  A rust _struct_.

  * :name - The field name in _snake case_
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:fields, list(Field.t()), default: [])
  end

  @valid_accesses [:ro, :rw, :ia, :wo]
  validates(:access, inclusion: @valid_accesses)

  def valid_name(name) do
    Atom.to_string(name) |> Kojin.Id.is_snake()
  end

  validates(:name, by: [function: &Struct.valid_name/1, message: "Struct.name must be snake case"])
end
