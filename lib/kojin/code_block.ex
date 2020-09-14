defmodule Kojin.CodeBlock do
  use TypedStruct

  alias Kojin.CodeBlock

  @delimiters %{open: "// α", close: "// ω"}
  @script_delimiters %{open: "# α", close: "# ω"}

  @doc """
  Return the common delimiters for script languages (`# α\\n   ...   \\n# ω`)
  """
  def script_delimiters(), do: @script_delimiters

  @typedoc ~S"""
  A place holder for a block in code.

  * :tag - An identifer for the block that must be unique within a generated file
  * :tag_prefix - A secondary identifier to help ensure uniqueness within target file
  *               If set will prefix tag like `#{tag_prefix}(#{tag})`
  * :delimiters - The open/close delimiters of the protected section
  * :header - The text preceding the protected section
  * :footer - The text following the protected section
  """
  typedstruct do
    field(:tag, String.t())
    field(:tag_prefix, String.t(), default: nil)
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
    defaults = [tag_prefix: nil, delimiters: @delimiters, header: nil, footer: nil]
    opts = Kojin.check_args(defaults, opts)

    %Kojin.CodeBlock{
      tag: tag,
      tag_prefix: Keyword.get(opts, :tag_prefix),
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
    do: code_block(tag, Kojin.check_args([delimiters: @script_delimiters], opts))

  def _block(delimiters, tag) do
    """
    #{delimiters.open} <#{tag}>
    #{delimiters.close} <#{tag}>
    """
  end

  @doc ~s"""
  The contents of the code block.

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
        ...> text(code_block(:sample_tag, tag_prefix: "Nested::"))
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
  def text(code_block=%CodeBlock{}) do
    tag =
      if(code_block.tag_prefix) do
        "#{code_block.tag_prefix}(#{code_block.tag})"
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
