defmodule Kojin.Sql.SqlType do
  use TypedStruct

  alias Kojin.Sql.SqlType

  @sql_types [
    :int,
    :double,
    :date,
    :timestamp,
    :char,
    :varchar,
    :boolean
  ]

  typedstruct enforce: true do
    field(:type, atom())
    field(:size, integer())
    field(:precision, integer())
    field(:nullable, boolean())
  end

  @doc """
  Creates a `Kojin.Sql.SqlType` from `type` and options including
  - `size`: Size for varchar
  - `precision`: For numbers

  ## Examples

      iex> import Kojin.Sql.SqlType
      ...> sql_type(:int)
      %Kojin.Sql.SqlType{ type: :int, size: nil, precision: nil, nullable: false }

      iex> import Kojin.Sql.SqlType
      ...> sql_type(:varchar, size: 32, nullable: true)
      %Kojin.Sql.SqlType{ type: :varchar, size: 32, precision: nil, nullable: true }

      iex> import Kojin.Sql.SqlType
      ...> sql_type(:oops)
      ** (RuntimeError) Type `oops` not supported

  """
  @spec sql_type(atom, list) :: SqlType.t()
  def sql_type(type, opts \\ []) do
    if(type not in @sql_types) do
      raise("Type `#{type}` not supported")
    end

    defaults = [
      size: nil,
      precision: nil,
      nullable: false
    ]

    opts = Kojin.check_args(defaults, opts)

    %SqlType{
      type: type,
      size: opts[:size],
      precision: opts[:precision],
      nullable: opts[:nullable]
    }
  end
end
