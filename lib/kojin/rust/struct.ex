defmodule Kojin.Rust.Struct do
  @moduledoc """
  Rust _struct_ definition.
  """

  require Logger
  alias Kojin.Rust.{Field, PopularTraits, Struct, TypeImpl, TraitImpl, Fn, Parm, Generic}
  alias Kojin.Utils
  import Utils
  import Kojin.Id

  use TypedStruct
  use Vex.Struct

  @allowed_custom_traits [
    :custom_debug,
    :custom_default,
    :custom_add,
    :custom_add_assign,
    :custom_mult,
    :custom_mult_assign
  ]

  @typedoc """
  A rust _struct_.

  * :name - The field name in _snake case_
  * :doc - Documentation for struct
  * :fields - List of struct fields
  """
  typedstruct enforce: true do
    field(:name, String.t())
    field(:type_name, String.t())
    field(:doc, String.t())
    field(:fields, list(Field.t()), default: [])
    field(:derivables, list(atom), default: [])
    field(:visibility, atom, default: :private)
    field(:with_new?, boolean, default: false)
    field(:generic, Generic.t(), default: nil)
    field(:impl, TypeImpl.t() | nil, default: nil)
    field(:trait_impls, list(TraitImpl.t()), default: [])
    field(:custom_traits, list(atom), default: [])
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

  def _make_field(opts) when is_list(opts) do
    Field.field(opts)
  end

  def _make_field(field = %Field{}) do
    field
  end

  @doc """
  Creates an `impl` populated with any specified accessors

  ## Examples

    Access of :ro provides a getter

      iex> import Kojin.Rust.{Struct, Field}
      ...> struct(:s, "An S", [ field(:x, :i32, "An x", access: :ro)]).impl
      ...> |> String.Chars.to_string()
      ...> |> Kojin.dark_matter()
      \"\"\"
      ///  Implementation for S
      impl S {
        // α <impl S>
        // ω <impl S>
        ////////////////////////////////////////////////////////////////////////////////////
        // --- pub functions ---
        ////////////////////////////////////////////////////////////////////////////////////
        ///  Getter for x
        ///
        ///  * _return_ - Value of x
        #[inline]
        pub fn x(self: & Self) -> i32 {
          self.x
        }
      }
      \"\"\" |> Kojin.dark_matter()

    Access of type :ro_ref provides a getter returning by ref.

      iex> import Kojin.Rust.{Struct, Field}
      ...> struct(:s, "An S", [ field(:x, :i32, "An x", access: :ro_ref)]).impl
      ...> |> String.Chars.to_string()
      ...> |> Kojin.dark_matter()
      \"\"\"
      ///  Implementation for S
      impl S {
        // α <impl S>
        // ω <impl S>
        ////////////////////////////////////////////////////////////////////////////////////
        // --- pub functions ---
        ////////////////////////////////////////////////////////////////////////////////////
        ///  Getter for x
        ///
        ///  * _return_ - Read access to x
        #[inline]
        pub fn x(self: & Self) -> &i32 {
          &self.x
        }
      }
      \"\"\" |> Kojin.dark_matter()

    Access of type :rw provides a getter and setter returning by value.

      iex> import Kojin.Rust.{Struct, Field}
      ...> struct(:s, "An S", [ field(:x, :i32, "An x", access: :rw)]).impl
      ...> |> String.Chars.to_string()
      ...> |> Kojin.dark_matter()
      \"\"\"
      ///  Implementation for S
      impl S {
        // α <impl S>
        // ω <impl S>
        ////////////////////////////////////////////////////////////////////////////////////
        // --- pub functions ---
        ////////////////////////////////////////////////////////////////////////////////////
        ///  Setter for x
        ///
        ///  * `x` - New value for x
        #[inline]
        pub fn set_x(self: & mut Self, x: i32) {
          self.x = x;
        }
        ///  Getter for x
        ///
        ///  * _return_ - Value of x
        #[inline]
        pub fn x(self: & Self) -> i32 {
          self.x
        }
      }
      \"\"\" |> Kojin.dark_matter()

    Access of type :rw_ref provides a getter and setter returning by ref.

      iex> import Kojin.Rust.{Struct, Field}
      ...> struct(:s, "An S", [ field(:foo, "Foo", "A foo", access: :rw_ref)]).impl
      ...> |> String.Chars.to_string()
      ...> |> Kojin.dark_matter()
      \"\"\"
      ///  Implementation for S
      impl S {
        // α <impl S>
        // ω <impl S>
        ////////////////////////////////////////////////////////////////////////////////////
        // --- pub functions ---
        ////////////////////////////////////////////////////////////////////////////////////
        ///  Getter for foo
        ///
        ///  * _return_ - Read access to foo
        #[inline]
        pub fn foo(self: & Self) -> & Foo {
          & self.foo
        }
        ///  Write accessor for foo
        ///
        ///  * _return_ - Write access to foo
        #[inline]
        pub fn foo_mut(self: & mut Self) -> & mut Foo {
          & mut self.foo
        }
      }
      \"\"\" |> Kojin.dark_matter()


    Custom functions may be specified.

      iex> import Kojin.Rust.{Struct, Field, TraitImpl}
      ...> struct(:s, "An S", [ field(:foo, "Foo", "A foo")], custom_traits: [:custom_default]).trait_impls
      ...> |> Enum.at(0)
      ...> |> String.Chars.to_string()
      ...> |> Kojin.dark_matter()
      \"\"\"
      ///  Implementation of Default for S
      impl Default for S {
        ///  Function to provide default value of type
        ///
        ///  * _return_ - Returns the default for the type
        fn default() -> Self {
          // α <fn default>
          // ω <fn default>
        }
      }
      \"\"\" |> Kojin.dark_matter()

  """
  @spec struct(String.t() | atom, String.t(), list(Field.t()), keyword) :: Kojin.Rust.Struct.t()
  def struct(name, doc, fields, opts \\ []) do
    defaults = [
      visibility: :private,
      derivables: [],
      impl: nil,
      trait_impls: [],
      impl?: false,
      generic: nil,
      with_new?: false,
      custom_traits: []
    ]

    name = Kojin.require_snake(name)

    struct_name = cap_camel(name)

    opts = Kojin.check_args(defaults, opts)

    fields = Enum.map(fields, &Struct._make_field/1)

    generic = if(opts[:generic] != nil, do: Generic.generic(opts[:generic]))

    accessors = accessors(fields)

    custom_traits =
      opts[:custom_traits]
      |> Enum.map(fn custom_trait ->
        if(custom_trait not in @allowed_custom_traits) do
          Logger.warn("Skipping custom trait #{custom_trait} for struct(#{name})")
        else
          case custom_trait do
            :custom_debug -> custom_fun_debug(struct_name, generic)
            :custom_default -> custom_fun_default(struct_name, generic)
            :custom_add -> custom_fun_add(struct_name, generic)
            :custom_add_assign -> custom_fun_add_assign(struct_name, generic)
            :custom_mult -> custom_fun_mult(struct_name, generic)
            :custom_mult_assign -> custom_fun_mult_assign(struct_name, generic)
          end
        end
      end)

    fn_new =
      if(opts[:with_new?]) do
        [fn_new(struct_name, fields)]
      else
        nil
      end

    impl =
      if(opts[:impl]) do
        TypeImpl.type_impl(opts[:impl])
      else
        if(Keyword.get(opts, :impl?) || !Enum.empty?(accessors) || fn_new) do
          TypeImpl.type_impl(struct_name)
        else
          nil
        end
      end

    impl =
      if(impl) do
        %{impl | functions: impl.functions ++ accessors ++ (fn_new || [])}
      else
        impl
      end

    result = %Struct{
      name: name,
      type_name: cap_camel(name),
      doc: doc,
      fields: fields,
      visibility: opts[:visibility],
      derivables: opts[:derivables],
      generic: generic,
      impl: impl,
      trait_impls: custom_traits
    }

    if(!Vex.valid?(result)) do
      raise ArgumentError,
        message: """
        Invalid `struct`:
        #{inspect(result, pretty: true)}
        ------- Struct Validations ---
        #{inspect(Vex.results(result), pretty: true)}
        """
    end

    result
  end

  defimpl String.Chars do
    @spec to_string(Kojin.Rust.Struct.t()) :: binary
    def to_string(struct), do: Struct.decl(struct)
  end

  defimpl Kojin.Rust.ToCode do
    @spec to_code(Struct.t()) :: binary
    def to_code(%Struct{} = struct), do: Struct.decl(struct)
  end

  @doc """
  Creates a _public_ `Kojin.Rust.Struct` by forwarding to `Kojin.Rust.Struct.struct` with
  extra option `[visibility: :pub]`
  """
  @spec pub_struct(String.t() | atom, String.t(), list(Field.t()), keyword) :: Struct.t()
  def pub_struct(name, doc, fields, opts \\ []) do
    struct(name, doc, fields, Keyword.merge(opts, visibility: :pub))
  end

  @spec decl(Struct.t()) :: binary
  def decl(%Struct{} = struct) do
    import Kojin.{Id, Rust.Utils}

    visibility = Kojin.Rust.visibility_decl(struct.visibility)
    derivables_decl = Kojin.Rust.derivables_decl(struct.derivables)

    {generic, bounds_decl} =
      if(struct.generic) do
        {Generic.code(struct.generic), Generic.bounds_decl(struct.generic)}
      else
        {"", ""}
      end

    join_content(
      [
        join_content([
          String.trim(triple_slash_comment(struct.doc)),
          derivables_decl,
          "#{visibility}struct #{cap_camel(struct.name)}#{generic}#{bounds_decl} {",
          indent_block(
            struct.fields
            |> Enum.map(&to_string/1)
            |> Enum.join(",\n")
          ),
          "}"
        ]),
        announce_section("struct impl", struct.impl),
        announce_section("trait impls", struct.trait_impls)
      ],
      "\n\n"
    )
  end

  defp accessors(fields) when is_list(fields) do
    fields
    |> Enum.filter(fn field -> field.access != nil end)
    |> Enum.map(fn field ->
      acc = field.access

      case acc do
        :ro ->
          [
            read_accessor(field)
          ]

        :ro_value ->
          [
            read_accessor_by_value(field)
          ]

        :ro_ref ->
          [
            read_accessor_ref(field)
          ]

        :rw ->
          [
            read_accessor(field),
            write_accessor(field)
          ]

        :rw_ref ->
          [
            read_accessor_ref(field),
            write_accessor_ref(field)
          ]
      end
    end)
    |> List.flatten()
  end

  defp read_accessor_by_value(%Field{} = field) do
    Fn.pub_fun(field.name, "Getter for #{field.name}", [:self_ref],
      body: "self.#{field.name}",
      return: {field.type, "Value of #{field.name}"},
      inline: true
    )
  end

  defp read_accessor(%Field{} = field) do
    if(field.type.primitive?) do
      read_accessor_by_value(field)
    else
      read_accessor_ref(field)
    end
  end

  defp read_accessor_ref(%Field{} = field) do
    import Kojin.Rust.Type

    Fn.pub_fun(field.name, "Getter for #{field.name}", [:self_ref],
      body: "& self.#{field.name}",
      return: {ref(field.type), "Read access to #{field.name}"},
      inline: true
    )
  end

  defp write_accessor(%Field{} = field) do
    Fn.pub_fun(
      "set_#{field.name}",
      "Setter for #{field.name}",
      [:self_mref, Parm.parm(field.name, field.type, "New value for #{field.name}")],
      body: "self.#{field.name} = #{field.name};",
      inline: true
    )
  end

  defp write_accessor_ref(%Field{} = field) do
    import Kojin.Rust.Type

    Fn.pub_fun(
      "#{field.name}_mut",
      "Write accessor for #{field.name}",
      [:self_mref],
      body: "& mut self.#{field.name}",
      return: {mref(field.type), "Write access to #{field.name}"},
      inline: true
    )
  end

  defp fn_new(struct_name, fields) do
    rust_name = cap_camel(struct_name)

    Fn.pub_fun(
      :new,
      "Initialize instance",
      fields
      |> Enum.map(fn field ->
        Parm.parm(field.name, field.type, "Initial value for #{field.name}")
      end),
      body:
        [
          "#{rust_name} {",
          fields
          |> Enum.map(fn field -> "#{field.name}" end)
          |> Enum.join(",\n"),
          "}"
        ]
        |> Enum.join("\n"),
      return: {struct_name, "Initialized `#{rust_name}`"},
      inline: true
    )
  end

  @spec custom_fun_debug(atom | binary | Kojin.Rust.Type.t(), any) :: Kojin.Rust.TraitImpl.t()
  def custom_fun_debug(struct_name, generic) do
    TraitImpl.trait_impl(PopularTraits.debug(), struct_name,
      generic: generic,
      generic_args: []
    )
  end

  defp custom_fun_default(struct_name, generic) do
    TraitImpl.trait_impl(PopularTraits.default(), struct_name,
      generic: generic,
      generic_args: generic || []
    )
  end

  defp custom_fun_add(struct_name, generic) do
    TraitImpl.trait_impl(PopularTraits.default(), struct_name, generic: generic)
  end

  defp custom_fun_add_assign(struct_name, generic) do
    TraitImpl.trait_impl(PopularTraits.default(), struct_name, generic: generic)
  end

  defp custom_fun_mult(struct_name, generic) do
    TraitImpl.trait_impl(PopularTraits.default(), struct_name, generic: generic)
  end

  defp custom_fun_mult_assign(struct_name, generic) do
    TraitImpl.trait_impl(PopularTraits.default(), struct_name, generic: generic)
  end
end
