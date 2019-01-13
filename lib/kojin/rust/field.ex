defmodule Kojin.Rust.Field do
  @moduledoc """
  Rust _struct_ _field_ definition.
  """

  use TypedStruct
  use Vex.Struct

  @typedoc """
  A *field* of a _struct_.

  * :name - The field name in _snake case_
  * :type - The rust type of the field
  * :pub - Specifies field should be `pub`
  * :pub_crate - Specifies field should be `pub(crate)`
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:type, String.t(), enforce: true)
    field(:is_by_ref, boolean, default: false)
    field(:access, atom, default: :ro)
    field(:pub, boolean, default: false)
    field(:pub_crate, boolean, default: false)
  end

  @valid_accesses [:ro, :rw, :ia, :wo]
  validates(:access, inclusion: @valid_accesses)

  def valid_name?(name) do
    Atom.to_string(name) |> Kojin.Id.is_snake()
  end

  validates(:name,
    by: [function: &Kojin.Rust.Field.valid_name?/1, message: "Field.name must be snake case"]
  )

  def field(opts \\ []) do
  end
end
