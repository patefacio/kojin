defmodule Kojin.Rust.Utils do
  @moduledoc """
  Rust utility functions.
  """

  def comment(text, opener) do
    result =
      text
      |> String.replace(~r/(?:\r|\n)+$/, "")
      |> String.split("\n")
      |> Enum.join("\n#{opener}")

    "#{opener}#{result}\n"
  end

  def triple_slash_comment(text) do
    comment(text, "///  ")
  end

  def script_comment(text) do
    comment(text, "#  ")
  end

  def indent_block(text, options \\ [])

  def indent_block(text, _) when text == nil do
    nil
  end

  def indent_block(text, options) do
    defaults = [indent: "  "]
    %{indent: indent} = Keyword.merge(defaults, options) |> Enum.into(%{})

    text
    |> String.split("\n")
    |> Enum.map(fn line -> "#{indent}#{line}" end)
    |> Enum.join("\n")
  end

  def pub_decl(obj) do
    cond do
      obj.pub -> "pub "
      obj.pub_crate -> "pub(crate) "
      true -> ""
    end
  end
end
