defmodule Kojin do
  @moduledoc """
  A module for general code generation as well as support
  for generating `rust` code.
  """

  @delimiters %{open: "// α", close: "// ω"}

  @doc "Returns default delimiters - with `//` style comments"
  def delimiters(), do: @delimiters

  @doc ~s"""
  Split the text by the specified `%{ open: ..., close: ... }` delimiters
  returning the list of split entries.

  ## Examples

      iex> Kojin._split("
      ...> generated prefix text
      ...> // α <block_name>
      ...> hand written text to preserve
      ...> // ω <block_name>
      ...> generated postfix text
      ...> ", %{open: "// α", close: "// ω"})
      %{ "block_name" => "\\n // α <block_name>\\n hand written text to preserve\\n // ω <block_name>" }
  """
  def _split(text, delimiters) do
    open = delimiters[:open]

    # Capture label in angle brackets and all text non-greedy, bounded by close
    prefixed_body = "<(.*?)>.*?"

    close = delimiters[:close]
    splitter = ~r{\n?[^\S\r\n]*?#{open}\s+#{prefixed_body}#{close}\s+<\1>}s

    Regex.scan(splitter, text)
    |> Enum.map(fn [matched, label] -> {label, matched} end)
    |> Map.new()
  end

  @doc """
  Merge generated content with code blocks with prior contents.
  """
  @spec merge(String.t(), String.t(), map) :: String.t()
  def merge(generated, prior, delimiters \\ @delimiters) do
    matches_without_content = _split(generated, delimiters)

    _split(prior, delimiters)
    |> Enum.reduce(generated, fn {label, contents}, generated ->
      if(!Map.has_key?(matches_without_content, label)) do
        IO.puts("WARNING: Losing block `#{delimiters.open} <#{label}>`")
        generated
      else
        String.replace(generated, matches_without_content[label], contents)
      end
    end)
  end

  @doc """
  Merge `generated` content into contents of `file_path` using
  protection `delimiters`.

  By default will print message `No change {file_path}` if no change or
  `Wrote {file_path}` if file was updated.

  To not print message pass `announce: false`.

  """
  @spec merge_generated_with_file(String.t(), String.t(), map, announce: boolean) :: nil
  def merge_generated_with_file(
        generated,
        file_path,
        delimiters \\ @delimiters,
        opts \\ [announce: true]
      )
      when is_map(delimiters) do
    prior =
      if File.exists?(file_path) do
        File.read!(file_path)
      else
        File.mkdir_p!(Path.dirname(file_path))
        ""
      end

    merged_content = Kojin.merge(generated, prior, delimiters)

    if(prior != merged_content) do
      File.write!(file_path, merged_content)

      if(opts[:announce]) do
        IO.puts("Wrote #{file_path}")
      end
    else
      if(opts[:announce]) do
        IO.puts("No change #{file_path}")
      end
    end

    nil
  end

  @doc ~s"""
  Ensures the name is snake case, raises `ArgumentError` if not.

  ## Examples

      iex> assert_raise(ArgumentError, "Name must be snake: `FooBar`", fn -> Kojin.require_snake(:FooBar) end)
      %ArgumentError{message: "Name must be snake: `FooBar`"}

      iex> Kojin.require_snake(:foo_bar)
      nil
  """
  def require_snake(name) when is_atom(name) do
    if !(Atom.to_string(name)
         |> Kojin.Id.is_snake()) do
      raise ArgumentError, "Name must be snake: `#{name}`"
    end
  end

  @spec check_args(keyword, keyword) :: keyword
  def check_args(defaults, passed) do
    unexpected = Keyword.keys(passed) -- Keyword.keys(defaults)

    if(!Enum.empty?(unexpected)) do
      raise ArgumentError,
        message:
          "Unexpected args: #{inspect(unexpected)} when allowed #{inspect(Keyword.keys(defaults))}"
    end

    Keyword.merge(defaults, passed)
  end

  def listify(l) when is_list(l), do: l

  def listify(l), do: [l]

  @doc """
  Returns string with all white space removed, useful for testing if whitespace
  is insignificant.

  ## Examples

      iex> import Kojin
      ...> dark_matter("\\tthis is text\\n\\twith white space\\n\\n")
      "thisistextwithwhitespace"
  """
  @spec dark_matter(binary) :: binary
  def dark_matter(t) when is_binary(t), do: String.replace(t, ~r/\s*/, "")

  def dark_matter(t), do: dark_matter("#{t}")
end
