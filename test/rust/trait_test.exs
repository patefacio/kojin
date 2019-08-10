defmodule TraitTest do
  use ExUnit.Case
  import Kojin.Rust.{Trait, Fn, Parm}

  test "empty trait" do
    doc = "Does traitish things"
    f1 = fun(:f1, "Does f2", [parm(:a, :A)], :i64)

    t = trait(:sample_trait, doc, [])
    assert(t.name == :sample_trait and t.doc == doc)
    assert(t.doc == doc)
    t = trait("sample_trait_2", doc, [])
    assert t.name == :sample_trait_2 and Enum.empty?(t.functions)

    t = trait(:t1, doc, [f1])
    assert Enum.at(t.functions, 0) == f1

    t = trait("sample_no_func", "Does sample type things")
    IO.puts("Trait #{inspect(t)}")
  end

  test "trait with function" do
    t =
      trait(:t, "with fn", [
        fun(
          :increment,
          "Adds 1 to [a]",
          [parm(:a, :A, "Value to increment")],
          :i32,
          "incremented value"
        )
      ])

    IO.puts("Trait #{inspect(t)}")
    t.functions |> Enum.each(fn f -> f |> IO.puts() end)
  end
end
