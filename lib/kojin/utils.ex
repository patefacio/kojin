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
    if text == nil do
      text
    else
      result =
        text
        |> String.replace(~r/(?:\r|\n)+$/, "")
        |> String.split("\n")
        |> Enum.join("\n#{opener}")

      "#{opener}#{result}"
    end
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
    %{indent: indent} = Kojin.check_args(defaults, options) |> Enum.into(%{})

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
  def join_content(content, separator \\ "\n")
  def join_content(nil, _), do: nil

  def join_content(content, separator) when is_list(content) do
    content
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.Chars.to_string/1)
    |> Enum.join(separator)
  end

  def join_content(scalar_content, _), do: "#{scalar_content}"

  @doc """
  Convert a `File.Stat` `mtime` to string.
  """
  @spec stat_time_to_str(any) :: binary
  def stat_time_to_str(t) do
    :calendar.universal_time_to_local_time(t)
    |> NaiveDateTime.from_erl!()
    |> String.Chars.to_string()
  end

  @doc """
  Announce status of requested generation of `path`.

  Reports one of:

  - `:updated`: The file has been updated
  - `:no_change`: The file has not changed
  - `:wrote_new` The file did not exist and has been written

  """
  @spec announce_file(atom | binary, binary, File.Stat.t()) :: binary
  def announce_file(:updated, path, stat), do: announce_file("Updated:  ", path, stat)
  def announce_file(:no_change, path, stat), do: announce_file("No Change:", path, stat)
  def announce_file(:wrote_new, path, stat), do: announce_file("Wrote New:", path, stat)

  def announce_file(status, path, stat) do
    stat =
      if(stat == nil) do
        File.stat!(path)
      else
        stat
      end

    time_str = Kojin.Utils.stat_time_to_str(stat.mtime)

    size =
      "#{Number.Delimit.number_to_delimited(stat.size, precision: 0)}" |> String.pad_leading(8)

    "#{status} #{time_str} (#{size}) bytes #{path}"
  end

  @doc """
  Time the provided function and print the timing using provided `label`
  """
  def time_function(function, label) do
    {time, value} =
      function
      |> :timer.tc()

    seconds =
      time
      |> Kernel./(1_000_000)

    IO.puts("------ Function #{label} -> #{seconds} seconds -------")

    value
  end
end
