defmodule Kojin.Sql.Ddl.Table do

  use TypedStruct

  alias Kojin.Sql.Ddl.{Column, Table}

  typedstruct enforce: true do
    field(:columns, list(Column.t()))
    field(:owner, binary)
    field(:foreign_keys, list(binary))
    field(:indices, list(binary))
  end

  def table(columns, opts \\ []) do

    defaults = [ owner: nil, foreign_keys: [], indices: []]

    opts = Kojin.check_args(defaults, opts)

    %Table{
      columns: columns,
      owner: opts[:owner],
      foreign_keys: opts[:foreign_keys],
      indices: opts[:indices]
    }
  end
end
