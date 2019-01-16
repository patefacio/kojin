defmodule Kojin.Rust.Utils do
  @moduledoc """
  Rust utility functions.
  """

  @commentLineTrailingWhite ~r"///\s+\n"
  @commentFinalTrailingWhite ~r"///\s+$"

  def triple_slash_comment(text) do
    indent = "  "

    result =
      text
      |> String.replace(~r/(?:\r|\n)*$/, "")
      |> String.split("\n")
      |> Enum.join("\n///#{indent}")
      |> String.replace(@commentLineTrailingWhite, "///\n")
      |> String.replace(@commentFinalTrailingWhite, "///")

    "///#{indent}#{result}\n"
  end
end
