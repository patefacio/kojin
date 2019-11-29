defmodule Kojin.Rust.TypeAlias do
  @moduledoc "Models a `type identifier =  ...` rust statement"

  use TypedStruct
  alias Kojin.Rust.TypeAlias
  alias Kojin.Id

  @typedoc """
  Models details of a `use ...` rust statement
  """
  typedstruct enforce: true do
    field(:name, atom)
    field(:aliased, String.t())
  end

  def type_alias(name, aliased, _opts \\ []) do
    %TypeAlias{
      name: name,
      aliased: aliased
    }
  end

  defimpl String.Chars do
    def to_string(type_alias),
      do: "type #{Id.cap_camel(type_alias.name)} = #{type_alias.aliased};"
  end
end
