defmodule Kojin.Rust.Clap.Arg do
  @moduledoc """
  Defines a Clap argument.
  """

  import Kojin
  import Kojin.Utils
  use TypedStruct
  alias Kojin.Rust.Clap.Arg
  import Kojin.Rust.{Attr, Type}

  @typedoc """
  Defines a Clap argument.
  """
  typedstruct enforce: true do
    field(:id, String)
    field(:as_argument, String.t())
    field(:doc, String.t())
    field(:short, String.t())
    field(:is_optional, boolean())
    field(:is_multiple, boolean())
    field(:default_value, String.t())
    field(:type, Type.t())
    field(:enum_values, list(String.t()))
  end

  @doc """
  Create a Clap argument from an _id_, doc comment and options

  - _short_: Short name for the argument
  - _is_optional_: Defines clap argument as optional
  - _is_multiple_: Defines clap argument as a list of values
  - _default_value_: Specifies a default for the argument
  - _type_: Type of argument

  ## Examples

    A minimal example (optional user name)

      iex> import Kojin.Rust.Clap.Arg
      ...> import Kojin.Rust.Type
      ...> arg(:user_name, "Name of user")
      %Kojin.Rust.Clap.Arg{
        type: :string,
        as_argument: "--user-name",
        default_value: nil,
        doc: "Name of user",
        id: "user_name",
        is_multiple: false,
        is_optional: false,
        short: nil,
        enum_values: []
      }

    An example with optional argument with short name and default value

      iex> import Kojin.Rust.Clap.Arg
      ...> import Kojin.Rust.Type
      ...> arg(:file_name, "Name of file", is_optional: true, short: "first_char_only", default_value: "foo.out")
      %Kojin.Rust.Clap.Arg{
        type: :string,
        as_argument: "--file-name",
        default_value: "foo.out",
        doc: "Name of file",
        id: "file_name",
        is_multiple: false,
        is_optional: true,
        short: "f",
        enum_values: []
      }

    An exmaple of typed argument, list of i64

      iex> import Kojin.Rust.Clap.Arg
      ...> arg(:search_value, "One or more search values", type: :i32)
      %Kojin.Rust.Clap.Arg{
        type: :i32,
        as_argument: "--search-value",
        doc: "One or more search values",
        default_value: nil,
        id: "search_value",
        is_multiple: false,
        is_optional: false,
        short: nil,
        enum_values: []
      }


  """

  def arg(id, doc, opts \\ [])

  def arg(id, doc, opts) when is_atom(id),
    do: arg(Atom.to_string(id), doc, opts)

  def arg(id, doc, opts) when is_binary(id) do
    require_snake(id)

    defaults = [
      is_optional: false,
      is_multiple: false,
      is_optional: false,
      default_value: nil,
      type: :string,
      short: nil,
      enum_values: []
    ]

    opts = Kojin.check_args(defaults, opts)

    short = case opts[:short] do
      nil -> nil
      true -> String.first(id)
      _ -> String.first(require_snake(opts[:short]))
    end

    %Arg{
      id: id,
      doc: doc,
      as_argument: "--" <> Kojin.Id.emacs(id),
      short: short,
      is_optional: opts[:is_optional],
      is_multiple: opts[:is_multiple],
      default_value: opts[:default_value],
      type: opts[:type],
      enum_values: opts[:enum_values]
    }
  end

  @doc """
  Create a Clap argument from an _id_, doc comment and options

  ## Examples

    A minimal example (optional user name)

      iex> import Kojin.Rust.Clap.Arg
      ...> arg(:user_name, "Names of users", is_multiple: true, short: "n")
      ...> |> attributes
      [%Kojin.Rust.Attr{id: ~s<clap(long, short = 'n')>, value: nil}]
  """

  def attributes(%Arg{} = arg) do
    [
      [
        "long",
        if arg.short do
          ~s<short = '#{arg.short}'>
        end,
        if arg.default_value do
          "default_value = #{double_quote(arg.default_value)}"
        end,
        if !Enum.empty?(arg.enum_values) do
          "arg_enum"
        end
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(", ")
      |> (&attr("clap(#{&1})")).()
    ]
  end
end
