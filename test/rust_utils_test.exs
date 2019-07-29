defmodule RustUtilsTest do
  use ExUnit.Case

  doctest Kojin.Rust.Utils
  import Kojin.Rust.Utils

  test "pub_decl" do
    assert pub_decl(%{pub: true}) == "pub "
    assert pub_decl(%{pub_crate: true}) == "pub(crate) "
    assert pub_decl(%{}) == ""
  end
end
