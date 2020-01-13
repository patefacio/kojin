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
    field(:visibility, atom)
  end

  def type_alias(%TypeAlias{} = type_alias), do: type_alias

  def type_alias(name, aliased, opts \\ []) do
    defaults = [visibility: :pub]
    opts = Kojin.check_args(defaults, opts)

    %TypeAlias{
      name: name,
      aliased: aliased,
      visibility: opts[:visibility]
    }
  end

  def type_alias([name, aliased]), do: type_alias(name, aliased)

  def pub_type_alias(%TypeAlias{} = type_alias), do: %{type_alias | visibility: :pub}

  def pub_type_alias(name, aliased, opts \\ []),
    do: %{type_alias(name, aliased, opts) | visibility: :pub}

  def pub_type_alias([name, aliased]), do: type_alias(name, aliased, visibility: :pub)

  defimpl String.Chars do
    def to_string(type_alias) do
      visibility = Kojin.Rust.visibility_decl(type_alias.visibility)
      "#{visibility}type #{Id.cap_camel(type_alias.name)} = #{type_alias.aliased};"
    end
  end
end
