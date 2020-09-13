defmodule Kojin.Sql.Dql.Query do
  use TypedStruct

  alias Kojin.Sql.Dql.{Query, ResultColumn, Join}

  typedstruct enforce: true do
    field(:result_columns, list(ResultColumn.t()))
    field(:table, binary)
    field(:joins, list(Join.t()))
    field(:group_by, list(binary))
    field(:having, binary)
    field(:order_by, list(binary))
  end

  @doc """
  Defines a query with:

  - result_columns: The expressions being returned from the query
  - table: The table being queried
  - joins: The list of tables being joined
  - group_by: The list of groupings
  - having: The having clause
  - order_by: The expressions to order the results by

  ## Examples

      iex> import Kojin.Sql.Dql.Query
      ...> query(["name", "age"], "person")
      %Kojin.Sql.Dql.Query{ result_columns: ["name", "age"], table: "person",
          joins: [], group_by: [], having: nil, order_by: [] }


  """
  def query(result_columns, table, opts \\ []) when is_list(result_columns) do
    defaults = [
      joins: [],
      group_by: [],
      having: nil,
      order_by: []
    ]

    opts = Kojin.check_args(defaults, opts)

    %Query{
      result_columns: result_columns,
      table: table,
      joins: opts[:joins],
      group_by: opts[:group_by],
      having: nil,
      order_by: opts[:order_by]
    }
  end
end
