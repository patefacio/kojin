defmodule Kojin.Utils do
  @moduledoc """
  Utility functions for general code generation.
  """

  @doc ~s"""
  Split lines of `text`, prepend `opener` text to each line and return the joined comment text.

  ## Examples

      iex> Kojin.Utils.comment("this is a test", "// ")
      "// this is a test"

  """
  @spec comment(binary, binary) :: binary
  def comment(text, opener) do
    result =
      text
      |> String.replace(~r/(?:\r|\n)+$/, "")
      |> String.split("\n")
      |> Enum.join("\n#{opener}")

    "#{opener}#{result}"
  end

  @doc ~s"""
  Wrap `text` in triple slash comment.

  ## Examples

      iex> Kojin.Utils.triple_slash_comment("this is a comment")
      "///  this is a comment"

      iex> Kojin.Utils.triple_slash_comment("Multi-line\\n\\t-1 first\\n\\t-2 second")
      "///  Multi-line\\n///  \\t-1 first\\n///  \\t-2 second"
  """
  @spec triple_slash_comment(binary) :: binary
  def triple_slash_comment(text) do
    comment(text, "///  ")
  end

  @doc ~s"""
  Wrap `text` in script-like comment.

  ## Examples

      iex> Kojin.Utils.script_comment("this is a comment")
      "#  this is a comment"

      iex> Kojin.Utils.script_comment("Multi-line\\n\\t-1 first\\n\\t-2 second")
      "#  Multi-line\\n#  \\t-1 first\\n#  \\t-2 second"
  """
  @spec script_comment(binary) :: binary
  def script_comment(text) do
    comment(text, "#  ")
  end

  @doc """
  Indent `text` with text `options.indent` (default "  ").
  If `text` is nil, returns nil.
  """
  def indent_block(text, options \\ [])

  def indent_block(text, _) when text == nil, do: nil

  def indent_block(text, options) do
    defaults = [indent: "  "]
    %{indent: indent} = Keyword.merge(defaults, options) |> Enum.into(%{})

    text
    |> String.split("\n")
    |> Enum.map(fn line -> "#{indent}#{line}" end)
    |> Enum.join("\n")
  end

  @doc ~s"""
  Convert elements of `content` to strings and join with `separator`,
  filtering out any empty strings or nil.

  ## Examples

    Empty strings and nil filtered: 

      iex> Kojin.Utils.join_content(["a", "", "c", nil])
      "a\\nc"

    To string conversions on elements:

      iex> Kojin.Utils.join_content([1, :two, "three"], ", ")
      "1, two, three"

  """
  def join_content(content, separator \\ "\n") when is_list(content) do
    content
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.Chars.to_string/1)
    |> Enum.join(separator)
  end
end
