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

  def announce_section(s, section, sep \\ "\n\n") do
    if section != nil && section != [] do
      """
      ////////////////////////////////////////////////////////////////////////////////////
      // --- #{s} ---
      ////////////////////////////////////////////////////////////////////////////////////

      #{join_content(section, sep)}
      """
    end
  end
end
