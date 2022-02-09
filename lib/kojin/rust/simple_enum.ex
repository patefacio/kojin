defmodule Kojin.Rust.SimpleEnum do
  @moduledoc """
  Rust _SimpleEnum_ definition.

  A `SimpleEnum` corresponds to a C++ style enum that simply enumerates a set of values.
  """

  alias Kojin.Rust.{SimpleEnum, TypeImpl, TraitImpl, Fn}
  alias Kojin.Utils
  import Utils
  import Kojin.Rust.{Utils, Type}

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
    field(:has_snake_conversions, boolean, default: false)
  end

  validates(:visibility, inclusion: Kojin.Rust.allowed_visibilities())

  validates(
    :derivables,
    by: [
      function: &Kojin.Rust.valid_derivables?/1,
      message: "Derivables must be in #{inspect(Kojin.Rust.allowed_derivables(), pretty: true)}"
    ]
  )

  validates(
    :name,
    by: [
      function: &Kojin.Rust.valid_name/1,
      message: "Struct.name must be snake case"
    ]
  )

  @doc """
  Creates a SimpleEnum from provided arguments.
  """
  @spec enum(name :: bitstring(), doc :: bitstring(), values :: list(atom), opts :: list()) ::
          SimpleEnum.t()
  def enum(name, doc, values, opts \\ []) do
    defaults = [
      visibility: :private,
      derivables: [],
      impl: nil,
      impl?: false,
      trait_impls: [],
      has_snake_conversions: false
    ]

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
      trait_impls: opts[:trait_impls],
      has_snake_conversions: opts[:has_snake_conversions]
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

  def decl(%SimpleEnum{} = simple_enum) do
    import Kojin.Id
    import Kojin.Rust

    values =
      simple_enum.values
      |> Enum.map(fn {e, doc} ->
        Kojin.Utils.join_content([triple_slash_comment(doc), cap_camel("#{e}")])
      end)
      |> Enum.join(",\n")

    derivables_decl = derivables_decl(simple_enum.derivables)
    visibility_decl = visibility_decl(simple_enum.visibility)

    impl =
      if(simple_enum.has_snake_conversions) do
        snake_functions = [
          Fn.pub_fun(
            :to_snake,
            "Convert #{simple_enum.name} to snake case string",
            [:self_ref],
            body:
              [
                "match self {",
                simple_enum.values
                |> Enum.map(fn {variant, _doc} ->
                  ~s(#{simple_enum.type_name}::#{cap_camel("#{variant}")} => "#{variant}")
                end)
                |> Enum.join(",\n"),
                "}"
              ]
              |> List.flatten()
              |> Kojin.Utils.join_content(),
            return: ref(:str),
            return_doc: "String literal of enum variant"
          ),
          Fn.pub_fun(
            :from_snake,
            "Create #{simple_enum.type_name} from snake case string",
            [[:snake_str, ref(:str), "Snake case name for #{simple_enum.type_name} value"]],
            body:
              [
                "match snake_str {",
                [
                  Enum.map(
                    simple_enum.values,
                    fn {variant, _doc} ->
                      ~s("#{variant}" => #{simple_enum.type_name}::#{cap_camel("#{variant}")})
                    end
                  ),
                  """
                  _ => panic!(
                  "Invalid snake conversion on {} into `#{simple_enum.type_name}`", snake_str)
                  """
                ]
                |> List.flatten()
                |> Enum.join(",\n"),
                "}"
              ]
              |> List.flatten()
              |> Kojin.Utils.join_content(),
            return: simple_enum.type_name,
            return_doc: "Enum variant corresponding to string literal"
          )
        ]

        if(simple_enum.impl) do
          simple_enum.impl |> TypeImpl.add_functions(snake_functions)
        else
          TypeImpl.type_impl(simple_enum.name, snake_functions)
        end
      end

    Kojin.Utils.join_content([
      derivables_decl,
      "#{visibility_decl}enum #{simple_enum.type_name} {",
      indent_block(values),
      "}",
      announce_section("enum impl", impl)
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
