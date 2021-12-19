defmodule ModuleTest do
  use ExUnit.Case

  import Kojin.Rust.{Module, Fn, Trait, TraitImpl, TypeImpl}

  test "module composition" do
    module(
      :top,
      "Top module",
      modules: [
        module(
          :middle,
          "Middle module",
          modules: [
            module(:inner, "Innermost module")
          ]
        )
      ]
    )
  end

  test "include_unit_test for fn" do
    t =
      trait(:t, "Some trait", [
        fun(:t_f, "Some trait function", [], return: :i32, return_doc: "A number")
      ])

    trait_impl = trait_impl(t, :i64, doc: "impl of trait", unit_tests: [:t_f])
    type_impl = type_impl(:foo, [], unit_tests: [:foo])

    _m =
      content(
        module(
          :m,
          "Some module",
          functions: [
            fun(:f, "Some function", [], include_unit_test: true)
          ],
          traits: [t],
          impls: [trait_impl, type_impl]
        )
      )

    assert 1 == 1

    # IO.puts(m)
  end
end
