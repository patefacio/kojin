import Kojin.Rust.{Crate, Binary, Module, CrateGenerator, Clap, Clap.Arg}

defmodule Generator do
  def generate do
    crate(
      :clap_sample,
      "Clap sample",
      module(:lib, "The Top Module"),
      binaries: [
        binary(:clap_sample, "Clap sample binary",
          clap:
            clap(
              "Program to do useful things",
              [
                arg(:arg_i16_optional, "Sample arg_i16_optional", type: :i16, is_optional: true),
                arg(:arg_i32, "Sample arg_i32", type: :i16),
                arg(:arg_bool, "Sample bool", type: :bool),
                arg(:arg_u16, "Sample u16", type: :u16, default_value: 32),
                arg(:c, "Sample argument", type: :string, default_value: "FOO", is_multiple: true)
              ]
            ),
          submodules: [
            module(:foo, "A foo module", type: :directory)
          ]
        )
      ]
    )
    |> generate_crate("/tmp/boo")
  end
end

Generator.generate()
