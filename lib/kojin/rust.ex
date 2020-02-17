defmodule Kojin.Rust do
  @moduledoc """
  Support for _rust_ code generation.
  """

  @allowed_derivables [
    :eq,
    :partial_eq,
    :ord,
    :partial_ord,
    :clone,
    :copy,
    :hash,
    :default,
    :zero,
    :debug,

    # Serde
    :serialize,
    :deserialize,

    # Failure
    :fail,

    # Diesel
    :queryable
  ]

  @doc """
  List of allowed derivables.

  This list is primarily to allow validation supplied derivables

  Values:

  \n#{
    @allowed_derivables
    |> Enum.map(fn d -> "  - `:#{d}`" end)
    |> Enum.join("\n")
  }
  """
  def allowed_derivables(), do: @allowed_derivables

  # Common derivables for generated structs
  @struct_common_derivables [
    :clone,
    :debug,
    :default,
    :deserialize,
    :partial_eq,
    :serialize
  ]

  # Common derivables for generated structs
  @enum_common_derivables [
    :clone,
    :copy,
    :debug,
    :deserialize,
    :partial_eq,
    :serialize
  ]

  @doc """
  List of common struct derivables.

  This list of derivables is useful for generation of basic structs
  so they can be serialized, copied, compared, etc.

  Values:

  \n#{
    @struct_common_derivables
    |> Enum.map(fn d -> "  - `:#{d}`" end)
    |> Enum.join("\n")
  }
  """
  def struct_common_derivables(), do: @struct_common_derivables

  @doc """
  List of common enum derivables.

  This list of derivables is useful for generation of basic enums
  so they can be serialized, copied, compared, etc.

  Values:

  \n#{
    @enum_common_derivables
    |> Enum.map(fn d -> "  - `:#{d}`" end)
    |> Enum.join("\n")
  }
  """
  def enum_common_derivables(), do: @enum_common_derivables

  @doc ~s"""
  Returns true if supplied `derivables` are all valid.

  ## Examples

      iex> Kojin.Rust.valid_derivables?([:copy, :eq])
      true

  """
  def valid_derivables?(derivables) do
    Enum.empty?(derivables -- @allowed_derivables)
  end

  @doc ~s"""
  Given list of derivables returns the corresponding rust `decl`.

  ## Examples

      iex> Kojin.Rust.derivables_decl([:copy])
      "#[derive(Copy)]"
  """
  def derivables_decl(derivables) do
    if(!Enum.empty?(derivables)) do
      import Kojin.Id

      disallowed = derivables -- @allowed_derivables

      if(!Enum.empty?(disallowed)) do
        raise ArgumentError,
          message: """
          Invalid derivables
          Provided: #{inspect(derivables, pretty: true)}
          Allowed:  #{inspect(@allowed_derivables, pretty: true)}
          """
      end

      values =
        derivables
        |> Enum.map(fn v -> cap_camel(v) end)
        |> Enum.join(", ")

      "#[derive(#{values})]"
    else
      ""
    end
  end

  @allowed_visibilities [
    :private,
    :pub,
    :pub_crate,
    :pub_self
  ]

  @doc """
  List of allowed visibilities.

  Values:

  \n#{
    @allowed_visibilities
    |> Enum.map(fn d -> "  - `:#{d}`" end)
    |> Enum.join("\n")
  }
  """
  def allowed_visibilities(), do: @allowed_visibilities

  @doc """
  Returns true if name is valid.

  Requires the name to be snake case.

  ## Examples

      iex> Kojin.Rust.valid_name(:FooBar)
      false

      iex> Kojin.Rust.valid_name(:foo_bar)
      true

      iex> Kojin.Rust.valid_name("FooBar")
      false

      iex> Kojin.Rust.valid_name("foo_bar")
      true
  """
  def valid_name(name) when is_atom(name) do
    Atom.to_string(name) |> valid_name
  end

  def valid_name(name) when is_bitstring(name) do
    name |> Kojin.Id.is_snake()
  end

  @doc """
  Given a [visibility] attribute returns the visibility declaration.

  For example visibility of `:pub` returns `"pub "`.
  """
  def visibility_decl(visibility) do
    case visibility do
      :private ->
        ""

      :pub ->
        "pub "

      :pub_crate ->
        "pub(crate) "

      :pub_self ->
        "pub(self) "

      _ ->
        raise ArgumentError,
          message: """
          Invalid visibility specifed: #{visibility}
          """
    end
  end

  @doc ~s"""
  Return tust style doc comment for documenting
  internal to a construct (e.g. for module documemntation)

  ## Example

      iex> Kojin.Rust.doc_comment("A basic module")
      "//! A basic module"
  """
  def doc_comment(text) do
    Kojin.Utils.comment(text, "//! ")
  end

  @doc "Add `[ visibility: :pub ]` option to `item`"
  def pub(item), do: %{item | visibility: :pub}
  @doc "Add `[ visibility: :pub_crate ]` option to `item`"
  def pub_crate(item), do: %{item | visibility: :pub_crate}
  @doc "Add `[ visibility: :pub_self]` option to `item`"
  def pub_self(item), do: %{item | visibility: :pub_self}
  @doc "Add `[ visibility: :private ]` option to `item`"
  def private(item), do: %{item | visibility: :private}
  @doc "Add `[ mut: true ]` option to `item`"
  def mut(item), do: %{item | mut: true}
end
