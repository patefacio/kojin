defmodule UtilsTest do
  use ExUnit.Case

  alias Kojin.Utils

  test "triple_slash_comment with cleaned trailing whitespace" do
    assert Utils.triple_slash_comment("
This is a test
Of the Emergency Broadcast System.
Don't panic



") == "///  " <> "
///  This is a test
///  Of the Emergency Broadcast System.
///  Don't panic"
  end

  test "script_comment with cleaned trailing whitespace" do
    assert Utils.script_comment("
This is a test
Of the Emergency Broadcast System.
Don't panic


") == "#  " <> "
#  This is a test
#  Of the Emergency Broadcast System.
#  Don't panic"
  end

  test "indent_block for nil is nil" do
    assert Utils.indent_block(nil) == nil
  end

  test "indent_block default indent" do
    assert Utils.indent_block("
This is a test
Of the Emergency Broadcast System.
Don't panic
") == "  " <> "
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
