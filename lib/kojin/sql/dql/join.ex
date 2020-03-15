defmodule Kojin.Sql.Dql.Join do
  use TypedStruct

  typedstruct enforce: true do
    field(:table, binary)
    field(:on, binary)
  end
end
