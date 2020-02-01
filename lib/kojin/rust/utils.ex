defmodule Kojin.Rust.Utils do
  @moduledoc """
  Rust utility functions.
  """

  import Kojin.Utils

  def pub_decl(obj) do
    case(obj) do
      %{pub: true} -> "pub "
      %{pub_crate: true} -> "pub(crate) "
      _ -> ""
    end
  end

  def announce_section(s, section, sep \\ "\n\n")

  def announce_section(_s, "", _sep), do: nil

  def announce_section(s, section, sep) do
    if section != nil && section != [] && section != "" do
      """
      ////////////////////////////////////////////////////////////////////////////////////
      // --- #{s} ---
      ////////////////////////////////////////////////////////////////////////////////////

      #{join_content(section, sep)}
      """
    end
  end

  def make_module_name(text) do
    text
    |> String.replace("<", "_")
    |> String.replace(">", "_")
    |> Kojin.Id.snake()
  end
end
