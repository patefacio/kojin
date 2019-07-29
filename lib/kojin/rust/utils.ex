defmodule Kojin.Rust.Utils do
  @moduledoc """
  Rust utility functions.
  """

  def pub_decl(obj) do
    case(obj) do
      %{pub: true} -> "pub "
      %{pub_crate: true} -> "pub(crate) "
      _ -> ""
    end
  end
end
