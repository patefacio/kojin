alias Kojin.Cpp.{UsingDirective, UsingDeclaration, Using}
import Kojin.Id

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

  defimpl String.Chars do
    def to_string(%UsingDirective{} = using_directive) do
      "use #{cap_snake(using_directive.lhs)}_t = #{using_directive.rhs};"
    end
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

  defimpl String.Chars do
    def to_string(%UsingDeclaration{} = using_declaration) do
    "use #{cap_snake(using_declaration.qualified_name)};"
    end
  end
end

#########
defmodule Kojin.Cpp.Using do
  def using(qualified_name),
    do: UsingDeclaration.using_declaration(qualified_name)

  def using(lhs, rhs),
    do: UsingDirective.using_directive(lhs, rhs)
end
