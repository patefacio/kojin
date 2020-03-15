defmodule Kojin.Rust.Const do
  @moduledoc """
  Rust _struct_ _constant_ definition.
  """

  use TypedStruct
  use Vex.Struct
  import Kojin.Id
  import Kojin.Rust
  alias Kojin.Rust.Type
  import Kojin.Utils

  alias Kojin.Rust.Const

  #  alias Kojin.Rust.Utils
  #  import Utils

  @typedoc """
  A *constant*.

  * :name - The field name in _snake case_
  * :type - The rust type of the field
  * :pub - Specifies field should be `pub`
  * :pub_crate - Specifies field should be `pub(crate)`
  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:type, Type.t(), enforce: true)
    field(:value, any)
    field(:visibility, atom, default: :private)
  end

  validates(:visibility, inclusion: Kojin.Rust.allowed_visibilities())

  validates(
    :name,
    by: [
      function: &Kojin.Rust.valid_name/1,
      message: "Const.name must be snake case"
    ]
  )

  def valid_name(name) do
    Atom.to_string(name)
    |> Kojin.Id.is_snake()
  end

  def const(name, doc, type, value, opts \\ []) do
    defaults = [visibility: :private]

    opts =
      Kojin.check_args(defaults, opts)
      |> Enum.into(%{})

    result = %Const{
      :name => name,
      :doc => doc,
      :type => Type.type(type),
      :value => value,
      :visibility => opts.visibility
    }

    if(!Vex.valid?(result)) do
      raise ArgumentError,
        message: """
        Invalid `const`:
        #{inspect(result)}
        ------- Const Validations ---
        #{inspect(Vex.results(result), pretty: true)}
        """
    end

    result
  end

  def const([name, doc, top, value]), do: const(name, doc, top, value)
  def const([name, doc, top, value, opts]), do: const(name, doc, top, value, opts)
  def const(%Const{} = const), do: const

  def pub_const(%Const{} = const), do: %{const | visibility: :pub}
  def pub_const(args) when is_list(args), do: %{const(args) | visibility: :pub}

  def pub_const(name, doc, type, value, opts \\ []),
    do: %{const(name, doc, type, value, opts) | visibility: :pub}

  def value_in_code(v) when is_binary(v), do: ~s("#{v}")
  def value_in_code(v), do: v

  def code(const) do
    visibility = visibility_decl(const.visibility)
    value = value_in_code(const.value)

    """
    #{String.trim(triple_slash_comment(const.doc))}
    #{visibility}const #{shout(const.name)}: #{const.type} = #{value};
    """
  end

  defimpl String.Chars do
    def to_string(const) do
      Const.code(const)
    end
  end
end
