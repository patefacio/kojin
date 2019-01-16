defmodule Kojin.Rust.Utils do
  @moduledoc """
  Rust utility functions.
  """

  def triple_slash_comment(text) do
    "/// #{text}\n"
  end
end
