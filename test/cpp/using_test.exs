defmodule UsingTest do
  use ExUnit.Case

  alias Kojin.Cpp.{UsingDeclaration, UsingDirective, Using}
  import UsingDeclaration
  import Using

  test "using declaration" do
    ud1 = %UsingDeclaration{qualified_name: "std::vector"}

    assert using_declaration("std::vector") == ud1

    IO.puts("The to_code is #{ud1}")
  end

  test "using function" do
    assert using("std::vector") == %UsingDeclaration{qualified_name: "std::vector"}

    ud1 = %UsingDirective{
      lhs: "vec_int",
      rhs: "std::vector< T >"
    }

    assert using("vec_int", "std::vector< T >") == ud1

    IO.puts("The to_code is `#{ud1}`")
  end
end
