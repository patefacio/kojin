defmodule Kojin.CodeBlock do
  use TypedStruct

  alias Kojin.CodeBlock

  @delimiters %{open: "// α", close: "// ω"}
  @script_delimiters %{open: "# α", close: "# ω"}

  @typedoc """
  A place holder for a block in code.

  * :tag - An identifer for the block that must be unique within a generated file
  * :delimiters - The open/close delimiters of the protected section
  * :header - The text preceding the protected section
  * :footer - The text following the protected section
  """
  typedstruct do
    field(:tag, String.t())
    field(:delimiters, String.t(), default: @delimiters)
    field(:header, String.t(), default: nil)
    field(:footer, String.t(), default: nil)
  end

  @doc """
  Create a `CodeBlock` with provided `tag` and options.

  Options:

  - `delimiters`: `%{open: "...", closed: "..."}`
  - `header`: Text preceding the protected code
  - `footer`: Text following the protected code

  """
  def code_block(tag, opts \\ [])

  def code_block(tag, opts) when not is_nil(tag) and is_atom(tag),
    do: code_block(Atom.to_string(tag), opts)

  def code_block(tag, opts) do
    opts = Keyword.merge([delimiters: @delimiters, header: nil, footer: nil], opts)

    %Kojin.CodeBlock{
      tag: tag,
      delimiters: Keyword.get(opts, :delimiters),
      header: Keyword.get(opts, :header),
      footer: Keyword.get(opts, :footer)
    }
  end

  @doc ~s"""
  Creates a code block using script style comment.

  ## Examples

      iex> import Kojin.CodeBlock
      ...> text(script_block(:sample_tag))
      "# α <sample_tag>\\n# ω <sample_tag>\\n"
  """
  def script_block(tag, opts \\ []),
    do: code_block(tag, Keyword.merge([delimiters: @script_delimiters], opts))

  def _block(delimiters, tag) do
    """
    #{delimiters.open} <#{tag}>
    #{delimiters.close} <#{tag}>
    """
  end

  @doc ~s"""
  The contents of the code block, with an optional `prefix` for the name.

  As text the code block is comprised of:

  - header if not nil
  - protect block (i.e. text surrounded by open/close delimiters if tag is not nil)
  - footer if not nil

  ## Examples

        iex> import Kojin.CodeBlock
        ...> text(code_block(:sample_tag))
        ~s{
        // α <sample_tag>
        // ω <sample_tag>
        } |> String.trim_leading 

        iex> import Kojin.CodeBlock
        ...> text(code_block(:sample_tag), "Nested::")
        ~s{
        // α <Nested::(sample_tag)>
        // ω <Nested::(sample_tag)>
        } |> String.trim_leading

        iex> import Kojin.CodeBlock
        ...> text(code_block(:sample_tag, header: "A header"))
        ~s{
        A header
        // α <sample_tag>
        // ω <sample_tag>
        } |> String.trim_leading

        iex> import Kojin.CodeBlock
        ...> text(code_block(:sample_tag, header: "A header", footer: "A footer"))
        ~s{
        A header
        // α <sample_tag>
        // ω <sample_tag>
        A footer
        } |> String.trim_leading

        iex> import Kojin.CodeBlock
        ...> text(code_block(nil, header: "A header", footer: "A footer"))
        ~s{
        A header
        A footer
        } |> String.trim_leading
  """
  def text(code_block, prefix \\ "") do
    tag =
      if("" != prefix) do
        "#{prefix}(#{code_block.tag})"
      else
        "#{code_block.tag}"
      end

    result =
      [
        code_block.header,
        if(code_block.tag) do
          String.trim_trailing(CodeBlock._block(code_block.delimiters, tag))
        else
          nil
        end,
        code_block.footer
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n")

    if(String.ends_with?(result, "\n")) do
      result
    else
      "#{result}\n"
    end
  end

  defimpl String.Chars do
    def to_string(code_block), do: CodeBlock.text(code_block)
  end
end
