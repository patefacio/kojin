defmodule Kojin.Rust.Clap.Arg do
  @moduledoc """
  Defines a Clap argument.
  """

  import Kojin
  import Kojin.Utils
  use TypedStruct
  alias Kojin.Rust.Clap.Arg
  import Kojin.Rust.Type

  @typedoc """
  Defines a Clap argument.
  """
  typedstruct enforce: true do
    field(:id, String)
    field(:as_argument, String.t())
    field(:doc, String.t())
    field(:short, String.t())
    field(:is_required, boolean())
    field(:is_multiple, boolean())
    field(:default_value, String.t())
    field(:type, Type.t())
  end

  @doc """
  Create a Clap argument from an _id_, doc comment and options

  - _short_: Short name for the argument
  - _is_required_: Defines clap argument as required
  - _is_multiple_: Defines clap argument as a list of values
  - _default_value_: Specifies a default for the argument
  - _type_: Type of argument

  ## Examples

    A minimal example (optional user name)

      iex> import Kojin.Rust.Clap.Arg
      ...> import Kojin.Rust.Type
      ...> arg(:user_name, "Name of user")
      %Kojin.Rust.Clap.Arg{
        type: ref(:str, :a),
        as_argument: "--user-name",
        default_value: nil,
        doc: "Name of user",
        id: "user_name",
        is_multiple: false,
        is_required: false,
        short: nil
      }

    An example with required argument with short name and default value

      iex> import Kojin.Rust.Clap.Arg
      ...> import Kojin.Rust.Type
      ...> arg(:file_name, "Name of file", is_required: true, short: "-f", default_value: "foo.out")
      %Kojin.Rust.Clap.Arg{
        type: ref(:str, :a),
        as_argument: "--file-name",
        default_value: "foo.out",
        doc: "Name of file",
        id: "file_name",
        is_multiple: false,
        is_required: true,
        short: "-f"
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
        is_required: false,
        short: nil
      }


  """

  def arg(id, doc, opts \\ [])

  def arg(id, doc, opts) when is_atom(id),
    do: arg(Atom.to_string(id), doc, opts)

  def arg(id, doc, opts) when is_binary(id) do
    require_snake(id)

    defaults = [
      is_required: false,
      is_multiple: false,
      default_value: nil,
      type: ref(:str, :a),
      short: nil
    ]

    opts = Kojin.check_args(defaults, opts)

    %Arg{
      id: id,
      doc: doc,
      as_argument: "--" <> Kojin.Id.emacs(id),
      short: opts[:short],
      is_required: opts[:is_required],
      is_multiple: opts[:is_multiple],
      default_value: opts[:default_value],
      type: opts[:type]
    }
  end

  @doc """
  Create a Clap argument from an _id_, doc comment and options

  ## Examples

    A minimal example (optional user name)

      iex> import Kojin.Rust.Clap.Arg
      ...> arg(:user_name, "Names of users", is_multiple: true, short: "n")
      ...> |> code
      ~s{
      .arg(
        Arg::with_name("user_name")
            .help("Names of users")
            .long("user-name")
            .short('n')
            .multiple(true)
      )
      } |> String.trim
  """

  def code(%Arg{} = arg) do
    [
      ".arg(",
      [
        """
        Arg::with_name(\"#{arg.id}\")
            .help(\"#{arg.doc}\")
            .long(\"#{arg.id |> Kojin.Id.emacs()}\")
        """
        |> String.trim_leading() |> String.trim,
        if arg.short do
          "    .short('#{arg.short}')"
        end,
        if arg.is_multiple do
          "    .multiple(true)"
        end
      ]
      |> Enum.join("\n")
      |> String.trim()
      |> indent_block(),
      ")"
    ]
    |> Enum.join("\n")
    |> String.trim()
    |> IO.inspect()
  end
end
