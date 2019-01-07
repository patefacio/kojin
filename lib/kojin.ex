defmodule Kojin do
  @delimiters %{open: "// α", close: "// ω"}

  @script_delimiters %{open: "# α", close: "# ω"}

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
        generated
      else
        String.replace(generated, matches_without_content[label], contents)
      end
    end)
  end
end
