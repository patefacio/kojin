defmodule KojinTest do
  use ExUnit.Case
  doctest Kojin

  @delimiters %{open: "// α", close: "// ω"}

  @script_delimiters %{open: "# α", close: "# ω"}

  test "split works if empty" do
    #    [] = Kojin._split("", @delimiters)
  end

  test "split returns text if no blocks" do
    #    [] = Kojin._split("foo", @delimiters)
  end

  test "split works with one block" do
    assert Kojin._split(
             "

Pre Lore ipsum

// α <foo>
the good stuff
// ω <foo>

Post Lore ipsum
",
             @delimiters
           ) == %{"foo" => "
// α <foo>
the good stuff
// ω <foo>"}
  end

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

  defmodule IdTest do
    use ExUnit.Case

    doctest Kojin.Id

    test "camel" do
      assert Kojin.Id.camel(["this", "is", "a", "test"]) == "thisIsATest"
    end

    test "camel 2" do
      assert Kojin.Id.camel(["this", "is", "a", "test"]) == "thisIsATest"
    end

    test "snake" do
      assert Kojin.Id.snake(["this", "is", "a", "test"]) == "this_is_a_test"
    end

    test "shout" do
      assert Kojin.Id.shout(["this", "is", "a", "test"]) == "THIS_IS_A_TEST"
    end

    test "emacs" do
      assert Kojin.Id.emacs(["this", "is", "a", "test"]) == "this-is-a-test"
    end

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
      a = %Kojin.Rust.Field{name: :bam_bam, doc: "This is a field", type: "goo", access: :rw}
      assert a == a
      assert Vex.errors(a) == []

      IO.puts(a.name)
    end

    test "Field" do
      alias Kojin.Rust.Field, as: Field

      assert %Field{name: :foo, type: :goo} == %Field{name: :foo, type: :goo}
    end
  end
end
