defmodule TraitTest do
  use ExUnit.Case
  import Kojin.Rust.{Trait, Fn, Parm}

  test "empty trait" do
    doc = "Does traitish things"
    fdoc = "Does f2"
    fparms = [[:a, :A, doc: "an A"], [:b, :B, doc: "the B"]]

    f1 = fun(:f1, fdoc, fparms, :i64)

    assert f1 == fun([:f1, fdoc, fparms, :i64])

    t = trait(:sample_trait, doc, [])
    assert(t.name == :sample_trait and t.doc == doc)
    assert(t.doc == doc)
    t = trait("sample_trait_2", doc, [])
    assert t.name == :sample_trait_2 and Enum.empty?(t.functions)
  end

  test "trait with function" do
    t =
      trait(:t, "Sample trait with fn", [
        fun(
          :increment,
          "Adds 1 to [a]",
          [parm(:a, :A, "Value to increment")],
          :i32,
          "incremented value"
        )
      ])

    IO.puts("#{t}")
  end
end
