alias Kojin.Rust
import Kojin.Utils
import Kojin.Rust
import Kojin.Rust.Attr

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
    field(:attrs, list(Attr.t()))
  end

  @doc ~s"""
  Creates a `Kojin.Rust.Use` object to model rust use statements within
  `module`, `function`, etc.

  ## Examples

      iex> Kojin.Rust.Use.use_("std::opts::Add") 
      ...> |> String.Chars.to_string()
      "use std::opts::Add;"

      iex> Kojin.Rust.Use.use_("SomeClass", attrs: ["cfg(test)"]) 
      ...> |> String.Chars.to_string() |> String.trim()
      ~s'''
      #[cfg(test)]
      use SomeClass;
      ''' |> String.trim()

  """

  def use_([path_name, opts]), do: Use.use_(path_name, opts)
  def use_(%Rust.Use{} = use), do: use

  def use_(path_name, opts \\ []) when is_binary(path_name) do
    defaults = [visibility: :private, attrs: []]
    opts = Kojin.check_args(defaults, opts)

    %Rust.Use{
      path_name: path_name,
      visibility: opts[:visibility],
      attrs: opts[:attrs] |> Enum.map(fn attr -> attr(attr) end)
    }
  end

  defimpl String.Chars do
    def to_string(use) do
      visibility = Rust.visibility_decl(use.visibility)

      if use.attrs == [] do
        "#{visibility}use #{use.path_name};"
      else
        "\n" <>
          """
          #{use.attrs |> Enum.map(fn attr -> external(attr) end)}
          #{visibility}use #{use.path_name};
          """
      end
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
      ...> import Rust.{Uses}
      ...> uses(["std::ops::Add", "std::ops::Sub"])
      ...> |> String.Chars.to_string
      ~s[
      // -- `(default/private)` use statements
      use std::ops::Add;
      use std::ops::Sub;
      ] |> String.trim()

  """
  def uses(%Rust.Use{} = use), do: uses([use])
  def uses(nil), do: uses([])

  def uses(uses) when is_list(uses) do
    uses =
      uses
      |> Enum.map(fn use -> Rust.Use.use_(use) end)

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
        |> Enum.sort(&(String.downcase(&1.path_name) <= String.downcase(&2.path_name)))

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
