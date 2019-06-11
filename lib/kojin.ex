defmodule Kojin do
  @moduledoc """
  A module for general code generation as well as support
  for generating `rust` code.
  """

  @delimiters %{open: "// α", close: "// ω"}

  @script_delimiters %{open: "# α", close: "# ω"}

  @doc """
  Split the text by the specified %{ open: ..., close: ... } delimiters
  returning the list of split entries.

  ## Examples

  iex> Kojin._split("
  ...> generated prefix text
  ...> // α <block_name>
  ...> hand written text to preserve
  ...> // ω <block_name>
  ...> generated postfix text
  ...> ", %{open: "// α", close: "// ω"})
  %{ "block_name" => "\n // α <block_name>\n hand written text to preserve\n // ω <block_name>" }
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
  @spec merge(String.t(), String.t(), keyword) :: String.t()
  def merge(generated, prior, delimiters \\ []) do
    delimiters =
      Enum.into(
        delimiters,
        if(Keyword.get(delimiters, :scriptlike), do: @script_delimiters, else: @delimiters)
      )

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

  def require_snake(name) when is_atom(name) do
    if !(Atom.to_string(name)
         |> Kojin.Id.is_snake()) do
      throw("Name must be snake: `#{name}`")
    end
  end


  def check_args(defaults, passed) do
    unexpected = Keyword.keys(passed) -- Keyword.keys(defaults)
    if(!Enum.empty?(unexpected)) do
      raise ArgumentError,
        message: "Unexpected args: #{inspect unexpected} when allowed #{inspect Keyword.keys(defaults)}"
    end
    Keyword.merge(defaults, passed)
  end

  def listify(l) when is_list(l) do
    l
  end

  def listify(l) do
    [l]
  end

  def dark_matter(t) when is_binary(t), do: String.replace(t, ~r/\s*/, "")

  def dark_matter(t), do: dark_matter("#{t}")


end
