require Logger

defmodule Kojin.PodRust.PodPackageToModule do
  use TypedStruct
  alias Kojin.Pod.{PodPackageSet, PodPackage, PodType, PodTypeRef, PodTypes, PodArray, PodMap}
  alias Kojin.Rust.{SimpleEnum, Struct, Module, Field, PopularTraits, Type, TypeAlias, Use}
  alias Kojin.PodRust.PodPackageToModule

  @pod_string PodTypes.pod_type(:string)

  @pod_int8 PodTypes.pod_type(:int8)
  @pod_int16 PodTypes.pod_type(:int16)
  @pod_int32 PodTypes.pod_type(:int32)
  @pod_int64 PodTypes.pod_type(:int64)

  @pod_uint8 PodTypes.pod_type(:uint8)
  @pod_uint16 PodTypes.pod_type(:uint16)
  @pod_uint32 PodTypes.pod_type(:uint32)
  @pod_uint64 PodTypes.pod_type(:uint64)

  @pod_char PodTypes.pod_type(:char)
  @pod_uchar PodTypes.pod_type(:uchar)
  @pod_date PodTypes.pod_type(:date)
  @pod_timestamp PodTypes.pod_type(:timestamp)
  @pod_boolean PodTypes.pod_type(:boolean)
  @pod_double PodTypes.pod_type(:double)

  @typedoc """
  Models the data required to transform pod package into rust module(s)
  """
  typedstruct enforce: true do
    field(:pod_package_set, PodPackageSet.t())
    field(:pod_package, PodPackage.t())
    field(:rs_enums, list(SimpleEnum.t()))
    field(:rs_structs, list(Struct.t()))
    field(:rs_uses, list(Use.t()))
    field(:type_aliases, list(TypeAlias.t()))
  end

  def pod_package_to_module(%PodPackageSet{} = pod_package_set, %PodPackage{} = pod_package) do
    alias Kojin.Id

    rs_enums =
      pod_package.pod_enums
      |> Enum.map(fn pe ->
        enum_type_name = Id.cap_camel(pe.id)
        enum_first_val_name = Id.cap_camel(List.first(pe.values).id)
        body = "#{enum_type_name}::#{enum_first_val_name}"

        SimpleEnum.enum(
          pe.id,
          pe.doc,
          pe.values
          |> Enum.map(fn ev -> {ev.id, ev.doc} end),
          visibility: :pub,
          derivables: Kojin.Rust.enum_common_derivables(),
          trait_impls: [
            Kojin.Rust.TraitImpl.trait_impl(
              PopularTraits.default(),
              enum_type_name,
              bodies: %{
                default: body
              }
            )
          ],
          has_snake_conversions: get_in(pe.properties, [:rust, :has_snake_conversions])
        )
      end)

    rs_structs =
      pod_package.pod_objects
      |> Enum.map(fn po ->
        modeled_derivables = get_rust_property(po, :derivables, [])
        modeled_field_visibility = get_rust_property(po, :field_visibility, :pub)
        modeled_field_access = get_rust_property(po, :field_access, nil)

        custom_traits = get_rust_property(po, :custom_traits, [])

        derivables =
          if Enum.empty?(modeled_derivables) do
            Kojin.Rust.struct_common_derivables()
          else
            modeled_derivables
          end

        Struct.struct(
          po.id,
          po.doc,
          po.fields
          |> Enum.map(fn field ->
            core_type = pod_type_to_rust_type(field.type)

            rust_type =
              if(get_rust_property(field, :boxed, nil)) do
                "Box<#{core_type}>"
              else
                core_type
              end

            rust_type =
              if(field.optional?) do
                "Option<#{rust_type}>"
              else
                rust_type
              end

            modeled_access = modeled_field_access || get_rust_property(field, :access, nil)

            Field.field(field.id, rust_type, field.doc,
              access: modeled_access,
              visibility: modeled_field_visibility
            )
          end),
          visibility: :pub,
          derivables:
            derivables
            |> MapSet.new()
            |> Enum.to_list(),
          with_new?: get_rust_property(po, :with_new?, false),
          custom_traits: custom_traits
        )
      end)

    split_refs =
      PodPackage.all_ref_types(pod_package)
      |> Enum.map(fn type ->
        type_id = type.type_id
        found = PodPackageSet.find_item_id(pod_package_set, type_id)

        if(found != nil) do
          {_item_id, [{package_id, _item} | _rest]} =
            PodPackageSet.find_item_id(pod_package_set, type_id)

          if(package_id == pod_package.id) do
            nil
          else
            {:use, "crate::#{package_id}::#{Id.cap_camel(type_id)}"}
          end
        else
          if(Enum.member?(pod_package_set.predefined_types, type_id)) do
            {:use, "crate::#{Id.cap_camel(type_id)}"}
          else
            {:missing, Id.cap_camel(type_id)}
          end
        end
      end)

    of_interest =
      split_refs
      |> Enum.reject(&is_nil/1)

    type_aliases =
      of_interest
      |> Enum.filter(fn {type, _value} -> type == :missing end)
      |> Enum.map(fn {type, value} ->
        Logger.info("Need a type for #{inspect(type)} #{inspect(value)}")
        TypeAlias.type_alias(value, "i32")
      end)
      |> Enum.sort()

    date_type = PodTypes.pod_type(:date)
    uses_date = Enum.any?(PodPackage.all_types(pod_package), fn {_pkg, t} -> t == date_type end)

    uses_map =
      PodPackage.all_field_types(pod_package)
      |> Enum.any?(fn type -> PodTypes.is_pod_map?(type) end)

    rs_uses =
      ([
         if(uses_date) do
           "crate::Date"
         end,
         if(uses_map) do
           "std::collections::BTreeMap"
         end
       ]
       |> Enum.reject(&is_nil/1)) ++
        (of_interest
         |> Enum.filter(fn {type, _value} -> type == :use end)
         |> Enum.map(fn {_type, value} -> Use.pub_use(value) end))

    %PodPackageToModule{
      pod_package_set: pod_package_set,
      pod_package: pod_package,
      rs_enums: rs_enums,
      rs_structs: rs_structs,
      rs_uses: rs_uses,
      type_aliases: type_aliases
    }
  end

  def pod_type_to_rust_type(%PodTypeRef{} = pod_type_ref) do
    Type.type(pod_type_ref.type_id)
  end

  def pod_type_to_rust_type(%PodType{} = pod_type) do
    case pod_type do
      @pod_string -> Type.type(:string)
      @pod_int64 -> Type.type(:i64)
      @pod_int8 -> Type.type(:i8)
      @pod_int16 -> Type.type(:i16)
      @pod_int32 -> Type.type(:i32)
      @pod_uint8 -> Type.type(:u8)
      @pod_uint16 -> Type.type(:u16)
      @pod_uint32 -> Type.type(:u32)
      @pod_uint64 -> Type.type(:u64)
      @pod_char -> Type.type(:char)
      @pod_uchar -> Type.type(:uchar)
      @pod_date -> Type.type(:date)
      @pod_timestamp -> Type.type(:timestamp)
      @pod_boolean -> Type.type(:bool)
      @pod_double -> Type.type(:f64)
      _ -> Type.type(:MISSING)
    end
  end

  def pod_type_to_rust_type(%PodArray{} = pod_array) do
    referred_type = pod_type_to_rust_type(pod_array.item_type)
    Type.type("Vec<#{referred_type}>")
  end

  def pod_type_to_rust_type(%PodMap{} = pod_map) do
    referred_type = pod_type_to_rust_type(pod_map.value_type)
    Type.type("BTreeMap<String, #{referred_type}>")
  end

  def to_module(%PodPackageToModule{} = pod_package_to_module) do
    pod_package = pod_package_to_module.pod_package

    Module.module(
      pod_package.id,
      pod_package.doc,
      enums: pod_package_to_module.rs_enums,
      structs: pod_package_to_module.rs_structs,
      uses: pod_package_to_module.rs_uses,
      type_aliases: pod_package_to_module.type_aliases,
      visibility: :pub
    )
  end

  defp get_rust_property(item, property, default) do
    get_in(
      item,
      [
        Access.key(:properties, %{}),
        Access.key(:rust, %{}),
        Access.key(property, default)
      ]
    )
  end
end
