import Kojin.Rust.{Crate, Binary, Module, CrateGenerator, Clap, Clap.Arg}

defmodule Generator do
  def generate do
    c =
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
                  arg(:a, "Something aweful")
                ]
              ),
            submodules: [
              module(:foo, "A foo module")
            ]

          )
        ]
      )

    IO.puts("BOOM")
    generate_crate(c, "/tmp/boo")
  end
end

Generator.generate()
