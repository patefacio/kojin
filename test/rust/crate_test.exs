defmodule CrateTest do
  use ExUnit.Case

  import Kojin.Rust.{Crate, Module, Fn}
  alias Kojin.Rust.Crate

  def make_module(name, doc, opts \\ []) do
    opts =
      Keyword.merge(
        [
          functions: [
            fun("#{name}_fun", "#{name} sample fn", [],
              body: ~s{println("#{name} function called");}
            )
          ]
        ],
        opts
      )

    module(name, doc, opts)
  end

  test "crate composition" do
    crate(:c1, "A simple crate", [
      make_module(:top, "Top module",
        type: :file,
        modules: [
          make_module(:middle, "Middle module",
            modules: [
              make_module(:inner_1, "Innermost module 1", type: :directory),
              make_module(:inner_2, "Innermost module 2", type: :inline),
              make_module(:inner_3, "Innermost module 3", type: :file)
            ]
          )
        ]
      )
    ])
    |> Crate.generate_spec("/tmp")
    |> Crate.generate()
    |> IO.inspect(pretty: true)
  end
end
