defmodule Kojin.Sql.Ddl.Column do
  use TypedStruct

  alias Kojin.Sql.SqlType
  alias Kojin.Sql.Ddl.Column

  typedstruct enforces: true do
    field(:name, binary)
    field(:type, SqlType.t())
    field(:index, boolean | nil)
    field(:foreign_key, binary | nil)
  end

  @doc """
  Creates a `Kojin.Sql.Column` from `name`, `type` and options including
  - `indices`: A list of index names, defined on the table, that the column belongs
  - `foreign_key_column`: A foreign_key constraint

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
  def column(name, %SqlType{} = type, opts \\ []) do
    defaults = [index: nil, foreign_key: nil]

    opts = Kojin.check_args(defaults, opts)

    %Column{
      name: name,
      type: type,
      index: opts[:index],
      foreign_key: opts[:foreign_key]
    }
  end
end
