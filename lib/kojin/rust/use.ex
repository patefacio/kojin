alias Kojin.Rust
import Kojin.Utils
import Kojin.Rust

defmodule Kojin.Rust.Use do
  @moduledoc "Models a `use ...` rust statement"

  use TypedStruct
  alias Rust.Use

  @typedoc """
  Models details of a `use ...` rust statement
  """
  typedstruct enforce: true do
    field(:path_name, String.t())
    field(:visibility, atom, default: :private)
  end

  @doc ~s"""
  Creates a `Kojin.Rust.Use` object to model rust use statements within
  `module`, `function`, etc.

  ## Examples

      iex> Kojin.Rust.Use.use("std::opts::Add") 
      %Kojin.Rust.Use{ path_name: "std::opts::Add", visibility: :private }

  """

  def use([path_name, opts]), do: Use.use(path_name, opts)
  def use(%Rust.Use{} = use), do: use

  def use(path_name, opts \\ []) when is_binary(path_name) do
    opts = Keyword.merge([visibility: :private], opts)

    %Rust.Use{
      path_name: path_name,
      visibility: opts[:visibility]
    }
  end

  defimpl String.Chars do
    def to_string(use) do
      visibility = Rust.visibility_decl(use.visibility)
      "#{visibility}use #{use.path_name};"
    end
  end
end

defmodule Kojin.Rust.Uses do
  @moduledoc "Models a collection of `use ...` rust statements"

  use TypedStruct

  @typedoc """
  Models a collection of `use ...` statements
  """
  typedstruct enforce: true do
    field(:uses, list(Use.t()))
  end

  @doc ~s"""
  Creates a `Rust.Uses`, which is just a list of `Rust.Use` instances.

  ## Examples

      iex> alias Kojin.Rust; 
      ...> import Rust.{Use, Uses}
      ...> uses(["std::ops::Add", "std::ops::Sub"]).uses
      [
          %Kojin.Rust.Use{path_name: "std::ops::Add", visibility: :private }, 
          %Kojin.Rust.Use{path_name: "std::ops::Sub", visibility: :private }
        ]

  """
  def uses(%Rust.Use{} = use), do: uses([use])
  def uses(nil), do: uses([])

  def uses(uses) when is_list(uses) do
    uses =
      uses
      |> Enum.map(fn use -> Rust.Use.use(use) end)

    %Rust.Uses{
      uses: uses
    }
  end

  defimpl String.Chars do
    def to_string(uses) do
      uses =
        uses.uses
        |> MapSet.new()
        |> MapSet.to_list()
        |> Enum.sort()

      uses
      |> Enum.group_by(fn use -> use.visibility end)
      |> Enum.map(fn {group, uses} ->
        visibility =
          if group == :private do
            "(default/private)"
          else
            visibility_decl(group) |> String.trim()
          end

        "// -- `#{visibility}` use statements\n" <> join_content(uses)
      end)
      |> Enum.join("\n\n")
    end
  end
end
