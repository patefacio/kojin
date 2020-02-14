alias Kojin.Cpp.{UsingDirective, UsingDeclaration, Using}

#####
defmodule Kojin.Cpp.UsingDirective do
  use TypedStruct

  typedstruct enforce: true do
    field(:lhs, binary)
    field(:rhs, binary)
  end

  def using_directive(lhs, rhs) do
    %UsingDirective{
      lhs: lhs,
      rhs: rhs
    }
  end
end

#######
defmodule Kojin.Cpp.UsingDeclaration do
  use TypedStruct

  typedstruct enforce: true do
    field(:qualified_name, binary)
  end

  def using_declaration(qualified_name) do
    %UsingDeclaration{
      qualified_name: qualified_name
    }
  end
end

#########
defmodule Kojin.Cpp.Using do
  def using(qualified_name),
    do: UsingDeclaration.using_declaration(qualified_name)

  def using(lhs, rhs),
    do: UsingDirective.using_directive(lhs, rhs)
end
