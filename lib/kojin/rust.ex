defmodule Kojin.Rust do

  defmodule Field do
    use TypedStruct

    typedstruct do
      field :name, String.t(), default: "John Smith"
      field :age, integer(), enforce: true
      field :email, String.t()
    end
  end
  
end
