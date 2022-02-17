defmodule ClapTest do
  use ExUnit.Case
  import Kojin.Rust.{Clap, Clap.Arg}
  alias Kojin.Rust.{Clap, Struct}

  test "Basics" do
    c =
      clap([
        arg(:arg_i16_optional, "Sample arg_i16_optional", type: :i16, is_optional: true),
        arg(:arg_i32, "Sample arg_i32", type: :i16),
        arg(:arg_bool, "Sample bool", type: :bool),
        arg(:arg_u16, "Sample u16", type: :u16, default_value: 32),
        arg(:c, "Sample argument", type: :string, default_value: "FOO", is_multiple: true),
      ])

    Clap.clap_struct(c)
    |> IO.inspect

    #assert Struct.decl(Clap.clap_structs(c)) == "bam"
  end
end
