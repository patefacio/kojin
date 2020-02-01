defmodule Kojin.Rust.Attr do
  @moduledoc """
  Models a rust `attribute`
  """

  alias Kojin.Rust.Attr

  use TypedStruct

  @typedoc """
  Models a rust attribute
  """
  typedstruct do
    field(:id, atom() | String.t())
    field(:value, String.t() | list(Attr.t()))
  end

  @doc ~S"""
  Created an `Kojin.Rust.Attr`.

  ## Examples

      iex> import Kojin.Rust.Attr
      ...> "#{attr(:test)}"
      "test"

      iex> import Kojin.Rust.Attr
      ...> ~s"#{attr(:id, "value")}"
      "id=value"

  """
  def attr(%Attr{} = attr), do: attr
  def attr(:cfg_test), do: attr("cfg(test)", nil)
  def attr(id, value \\ nil)

  def attr(id, value) when is_atom(id) or is_binary(id) do
    %Attr{
      id: id,
      value: value
    }
  end

  @doc ~S"""
  Combine multiple `Kojin.Rust.Attr` with _AND_.

  ## Examples

      iex> import Kojin.Rust.Attr
      ...> "#{and_([:linux, :windows])}"
      "and(linux, windows)"

      iex> import Kojin.Rust.Attr
      ...> "#{and_([:linux, attr(:debug, "true")])}"
      "and(linux, debug=true)"

  """
  def and_(items) when is_list(items) do
    %Attr{
      id: :__and,
      value:
        items
        |> Enum.map(fn item -> attr(item) end)
    }
  end

  @doc """
  Returns the internal representation for the attribute.

  ## Examples

      iex> import Kojin.Rust.Attr
      ...> internal(attr(:debug))
      ...> |> String.Chars.to_string()
      "#![debug]"

  """
  def internal(%Attr{} = attr) do
    "#![#{attr}]"
  end

  @doc """
  Returns the external representation for the attribute.

  ## Examples

      iex> import Kojin.Rust.Attr
      ...> external(attr(:debug))
      ...> |> String.Chars.to_string()
      "#[debug]"

  """
  def external(%Attr{} = attr) do
    "#[#{attr}]"
  end

  defimpl String.Chars do
    def to_string(%Attr{} = attr) do
      import Kojin.Utils

      case attr.id do
        :__and ->
          ~s[and(#{join_content(attr.value, ", ")})]

        _ ->
          if attr.value do
            "#{attr.id}=#{attr.value}"
          else
            "#{attr.id}"
          end
      end
    end
  end
end
