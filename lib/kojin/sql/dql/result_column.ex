defmodule Kojin.Sql.Dql.ResultColumn do
  use TypedStruct

  typedstruct enforce: true do
    field(:expr, binary)
    field(:alias, binary)
    field(:group, boolean)
    field(:rollup, boolean)
  end

  def result_column(expr, opts \\ []) do
  end
end
