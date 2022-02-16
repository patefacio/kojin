defmodule ClapTest do
  use ExUnit.Case
  import Kojin.Rust.{Clap, Clap.Arg}
  alias Kojin.Rust.{Clap, Struct}

  test "Basics" do
    c =
      clap("Here is my app doc", [
        arg(:a, "Sample argument", type: :i16),
        arg(:b, "Sample argument", default_value: 32),
        arg(:b, "Sample argument", type: :string, default_value: "FOO"),
      ])

    IO.puts(Struct.decl(Clap.clap_struct(c)))
    assert Struct.decl(Clap.clap_struct(c)) == "bam"
  end
end
