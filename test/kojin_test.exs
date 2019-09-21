defmodule KojinTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  doctest Kojin
  doctest Kojin.CodeBlock
  doctest Kojin.Id
  doctest Kojin.Rust
  doctest Kojin.Rust.Field
  doctest Kojin.Rust.Fn
  doctest Kojin.Rust.Parm
  doctest Kojin.Rust.Trait
  doctest Kojin.Rust.TraitImpl
  doctest Kojin.Rust.TypeImpl
  doctest Kojin.Rust.Utils
  doctest Kojin.Rust.Use
  doctest Kojin.Rust.Uses
  doctest Kojin.Utils

  @delimiters %{open: "// α", close: "// ω"}

  test "split works with multiple blocks" do
    assert Kojin._split(
             "
Pre Lore ipsum

// α <foo>
the good stuff
// ω <foo>
Middle Lore ipsum

// α <goo>
more good stuff!
// ω <goo>
Pre Lore ipsum

",
             @delimiters
           ) == %{
             "foo" => "
// α <foo>
the good stuff
// ω <foo>",
             "goo" => "
// α <goo>
more good stuff!
// ω <goo>"
           }
  end

  test "merge most common" do
    assert Kojin.merge(
             "
Pre Lore IPSUM

// α <foo>
// ω <foo>

Post Lore IPSUM
",
             "
Pre Lore ipsum

// α <foo>
the good stuff
// ω <foo>

Post Lore ipsum
"
           ) == "
Pre Lore IPSUM

// α <foo>
the good stuff
// ω <foo>

Post Lore IPSUM
"
  end

  test "merge missing block" do
    template = "
Pre Lore IPSUM

Post Lore IPSUM
"
    prior_text = "
Pre Lore ipsum

// α <foo>
the good stuff
// ω <foo>

Post Lore ipsum
"
    assert Kojin.merge(template, prior_text) == "
Pre Lore IPSUM

Post Lore IPSUM
"

    assert capture_io(fn -> Kojin.merge(template, prior_text) end) ==
             "WARNING: Losing block `// α <foo>`\n"
  end

  defmodule IdTest do
    use ExUnit.Case

    test "loop" do
      words = ["wee", "willie", "winkie"]

      1..100_000
      |> Enum.each(fn _ -> assert Kojin.Id.emacs(words) == "wee-willie-winkie" end)
    end

    test "words" do
      assert Kojin.Id.words("this_is_cool") == ["this", "is", "cool"]
      assert Kojin.Id.words("thisIsCool") == ["this", "is", "cool"]
      assert Kojin.Id.words("ThisIsCool") == ["this", "is", "cool"]
      assert Kojin.Id.words("THIS_IS_COOL") == ["this", "is", "cool"]
    end

    test "is_snake" do
      assert Kojin.Id.is_snake("this_is_snake_case") == true
      assert Kojin.Id.is_snake("this_is_Not_snake_case") == false
    end

    test "id" do
      assert Kojin.Id.id("thisIsCool") == "this_is_cool"
    end

    test "field" do
      a = %Kojin.Rust.Field{name: :bam_bam, doc: "This is a field", type: "goo"}
      assert a == a
      assert Vex.errors(a) == []
    end

    test "Field" do
      alias Kojin.Rust.Field, as: Field

      assert %Field{name: :foo, type: :goo} == %Field{name: :foo, type: :goo}
    end

    test "merge file with `announce`" do
      assert capture_io(fn ->
               Kojin.merge_generated_with_file(
                 """
                 fn foo_bar() {
                   this_is_sample_data = 1;

                   // α <sample_identifier>
                   // ω <sample_identifier>
                 }
                 """,
                 "test/rust/test_data_files/sample_generated_file.txt"
               )
             end) =~ ~r{No Change: .* test/rust/test_data_files/sample_generated_file.txt.*}
    end

    test "merge file with `announce` false" do
      assert capture_io(fn ->
               Kojin.merge_generated_with_file(
                 """
                 fn foo_bar() {
                   this_is_sample_data = 1;

                   // α <sample_identifier>
                   // ω <sample_identifier>
                 }
                 """,
                 "test/rust/test_data_files/sample_generated_file.txt",
                 Kojin.delimiters(),
                 announce: false
               )
             end) ==
               ""
    end
  end
end
