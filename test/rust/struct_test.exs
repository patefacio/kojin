defmodule StructTest do
  use ExUnit.Case
  import Kojin.Rust.{Struct, Field, ToCode}

  test "s" do
    # s =
    #   struct(:s, "This is an ssssss", [
    #     field(:f, :i32, "Field 1"),
    #     [:f2, :i32, "Field 2"],
    #     [:f3, "i32"]
    #   ])

    # IO.puts(to_code(s))

    age_assumptions =
      struct(
        :age_assumptions,
        "Assumptions regarding the ages of a person _at retirement_, _at death_, etc.\n",
        [
          field(:death_age, :i64, "Age at death.\n", visibility: :pub),
          field(:retirement_age, :i64, "Age of retirement - where labor incomes are ended.\n",
            visibility: :pub
          )
        ]
      )

    to_code(age_assumptions)
    # TODO: assert
  end
end
