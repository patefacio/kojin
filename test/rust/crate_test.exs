defmodule CrateTest do
  use ExUnit.Case

  import Kojin.Rust.{Crate, Module, Fn, Struct, Field, Trait}
  alias Kojin.Rust.{CrateGenerator}

  def make_module(name, doc, opts \\ []) do
    opts =
      Keyword.merge(
        [
          functions: [
            fun("#{name}_fun_1", "#{name} sample fn 1", [],
              body: ~s{println!("#{name} function 1 called");}
            ),
            fun("#{name}_fun_2", "#{name} sample fn 2", [],
              body: ~s{println!("#{name} function 2 called");}
            )
          ],
          structs: [
            struct(
              "#{name}_struct_1",
              "Struct #{name}_struct_1 docs",
              [
                field("f_1", :i32),
                field("f_2", :i64)
              ]
            ),
            struct(
              "#{name}_struct_2",
              "Struct #{name}_struct_2 docs",
              [
                field("f_1", :i32),
                field("f_2", :i64)
              ]
            )
          ],
          traits: [
            trait("#{name}_trait_1", "Trait 1 doc", [
              fun(:f_1, "Trait 1 f 1", []),
              fun(:f_2, "Trait 1 f 2", [])
            ]),
            trait("#{name}_trait_2", "Trait 2 doc", [
              fun(:f_1, "Trait 2 f 1", []),
              fun(:f_2, "Trait 2 f 2", [])
            ])
          ]
        ],
        opts
      )

    module(name, doc, opts)
  end

  test "crate composition" do
    crate(
      :c1,
      "A simple crate",
      make_module(:lib, "Top module",
        type: :file,
        modules: [
          make_module(:middle, "Middle module",
            visibility: :pub,
            modules: [
              make_module(:inner_1, "Innermost module 1", type: :directory),
              make_module(:inner_2, "Innermost module 2",
                type: :inline,
                visibility: :pub,
                modules: [make_module(:file_in_inline, "File module in inline")]
              ),
              make_module(:inner_3, "Innermost module 3", type: :file)
            ]
          )
        ]
      )
    )
    |> CrateGenerator.generate_crate("/tmp/tmp_crate")
  end
end
