defmodule UsingTest do
  use ExUnit.Case

  alias Kojin.Cpp.{UsingDeclaration, UsingDirective, Using}
  import UsingDeclaration
  import UsingDirective
  import Using

  test "using declaration" do
    assert using_declaration("std::vector") == %UsingDeclaration{qualified_name: "std::vector"}
  end

  test "using function" do
    assert using("std::vector") == %UsingDeclaration{qualified_name: "std::vector"}

    assert using("vec_int", "std::vector< T >") == %UsingDirective{
             lhs: "vec_int",
             rhs: "std::vector< T >"
           }
  end
end
