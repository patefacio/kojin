defmodule RustUtilsTest do
  use ExUnit.Case

  doctest Kojin.Rust.Utils
  alias Kojin.Rust.Utils

  test "triple_slash_comment with cleaned trailing whitespace" do
    assert Utils.triple_slash_comment("
This is a test
Of the Emergency Broadcast System.
Don't panic



") == "///  
///  This is a test
///  Of the Emergency Broadcast System.
///  Don't panic
"
  end

  test "script_comment with cleaned trailing whitespace" do
    assert Utils.script_comment("
This is a test
Of the Emergency Broadcast System.
Don't panic


") == "#  
#  This is a test
#  Of the Emergency Broadcast System.
#  Don't panic
"
  end

  test "indent_block default indent" do
    assert Utils.indent_block("
This is a test
Of the Emergency Broadcast System.
Don't panic
") == "  
  This is a test
  Of the Emergency Broadcast System.
  Don't panic
  "
  end

  test "indent_block supplied indent" do
    assert Utils.indent_block("
This is a test
Of the Emergency Broadcast System.
Don't panic
",
             indent: "...."
           ) == "....
....This is a test
....Of the Emergency Broadcast System.
....Don't panic
...."
  end
end
