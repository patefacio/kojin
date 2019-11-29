defmodule Kojin.Rust.SimpleEnum do
  @moduledoc """
  Rust _SimpleEnum_ definition.

  A `SimpleEnum` corresponds to a C++ style enum that simply enumerates a set of values.
  """

  alias Kojin.Rust.{SimpleEnum, TypeImpl}
  alias Kojin.Utils
  import Utils

  use TypedStruct
  use Vex.Struct

  @typedoc """
  An *enum* (i.e. discriminating type)

  """
  typedstruct do
    field(:name, atom, enforce: true)
    field(:type_name, binary, enforce: true)
    field(:doc, String.t())
    field(:values, list(), enforce: true)
    field(:derivables, list(atom), default: [])
    field(:visibility, atom, default: :private)
    field(:impl, TypeImpl.t() | nil, default: nil)
    field(:trait_impls, list(TraitImpl.t()), default: [])
  end

  validates(:visibility, inclusion: Kojin.Rust.allowed_visibilities())

  validates(:derivables,
    by: [
      function: &Kojin.Rust.valid_derivables?/1,
      message: "Derivables must be in #{inspect(Kojin.Rust.allowed_derivables(), pretty: true)}"
    ]
  )

  validates(:name,
    by: [function: &Kojin.Rust.valid_name/1, message: "Struct.name must be snake case"]
  )

  @doc """
  Creates a SimpleEnum from provided arguments.
  """
  @spec enum(name :: bitstring(), doc :: bitstring(), values :: list(atom), opts :: list()) ::
          SimpleEnum.t()
  def enum(name, doc, values, opts \\ []) do
    defaults = [visibility: :private, derivables: [], impl: nil, impl?: false, trait_impls: []]

    impl =
      if(opts[:impl]) do
        TypeImpl.type_impl(opts[:impl])
      else
        if(Keyword.get(opts, :impl?)) do
          TypeImpl.type_impl(name)
        else
          nil
        end
      end

    opts = Kojin.check_args(defaults, opts)

    result = %SimpleEnum{
      name: name,
      type_name: Kojin.Id.cap_camel(name),
      doc: doc,
      values: values,
      derivables: opts[:derivables],
      visibility: opts[:visibility],
      impl: impl,
      trait_impls: opts[:trait_impls]
    }

    if(!Vex.valid?(result)) do
      raise ArgumentError,
        message: """
        Invalid `enum` args:
        name: #{name}
        doc: #{doc}
        values: #{values}
        visibility: #{opts[:visibility]}
        ------- Struct Validations ---
        #{inspect(Vex.results(result), pretty: true)}
        """
    end

    result
  end

  def decl(enum) do
    import Kojin.Id
    import Kojin.Rust

    values =
      enum.values
      |> Enum.map(fn {e, doc} ->
        Kojin.Utils.join_content([triple_slash_comment(doc), cap_camel("#{e}")])
      end)
      |> Enum.join(",\n")

    derivables_decl = derivables_decl(enum.derivables)
    visibility_decl = visibility_decl(enum.visibility)

    Kojin.Utils.join_content([
      derivables_decl,
      "#{visibility_decl}enum #{enum.type_name} {",
      indent_block(values),
      "}"
    ])
  end

  defimpl String.Chars do
    def to_string(enum) do
      import Kojin.Rust.Utils

      Kojin.Utils.join_content([
        triple_slash_comment(
          if String.length(enum.doc) > 0 do
            enum.doc
          else
            "TODO: document #{enum.name}"
          end
        ),
        SimpleEnum.decl(enum),
        if(enum.impl) do
          announce_section("enum impl", enum.impl)
        end,
        if(!Enum.empty?(enum.trait_impls)) do
          announce_section("#{enum.type_name} trait impls", enum.trait_impls)
        end
      ])
    end
  end
end

defmodule Kojin.Rust.UnitVariant do
  use TypedStruct
  use Vex.Struct

  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:value, any)
  end
end

defmodule Kojin.Rust.TupleVariant do
  use TypedStruct
  use Vex.Struct

  alias Kojin.Rust.Field

  typedstruct do
    field(:name, atom, enforce: true)
    field(:doc, String.t())
    field(:fields, Field.t())
  end

  def tv(name, value) do
    IO.puts("TV -> #{name} -> #{value}")
  end
end
