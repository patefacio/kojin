defmodule Kojin.PodRust.ToCrate do
  alias Kojin.Pod.{PodPackageSet, PodPackage, PodType, PodArray, PodTypeRef}
  alias Kojin.Rust.{CrateGenerator}
  import Kojin.Rust.{Crate, Module, Struct, Field, SimpleEnum}
  import Kojin.Pod.PodTypes

  @pod_string pod_type(:string)

  @pod_int8 pod_type(:int8)
  @pod_int16 pod_type(:int16)
  @pod_int32 pod_type(:int32)
  @pod_int64 pod_type(:int64)

  @pod_uint8 pod_type(:uint8)
  @pod_uint16 pod_type(:uint16)
  @pod_uint32 pod_type(:uint32)
  @pod_uint64 pod_type(:uint64)

  @pod_char pod_type(:char)
  @pod_uchar pod_type(:uchar)
  @pod_date pod_type(:date)
  @pod_timestamp pod_type(:timestamp)

  def pod_type_to_rust_type(%PodTypeRef{} = pod_type_ref) do
    Kojin.Rust.Type.type(pod_type_ref.type_id)
  end

  def pod_type_to_rust_type(%PodArray{} = pod_array) do
    referred_type = pod_type_to_rust_type(pod_array.item_type)
    Kojin.Rust.Type.type("Vec<#{referred_type}>")
  end

  def pod_type_to_rust_type(%PodType{} = pod_type) do
    alias Kojin.Rust.Type

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
      _ -> Type.type(:bool)
    end
  end

  def to_module(%PodPackage{} = pod_package) do
    module(pod_package.id, pod_package.doc,
      ## Add the enums
      enums:
        pod_package.pod_enums
        |> Enum.map(fn pe ->
          enum(
            pe.id,
            pe.doc,
            pe.values
            |> Enum.map(fn ev -> {ev.id, ev.doc} end)
          )
        end),
      ## Add module for each object
      modules:
        pod_package.pod_objects
        |> Enum.map(fn po ->
          module(
            po.id,
            po.doc,
            structs: [
              struct(
                po.id,
                po.doc,
                po.fields
                |> Enum.map(fn f -> field(f.id, pod_type_to_rust_type(f.type), f.doc) end)
              )
            ]
          )
        end)
    )
  end

  def to_crate(%PodPackageSet{} = pod_package_set, crate_name) when is_atom(crate_name) do
    crate(
      crate_name,
      pod_package_set.doc,
      module(:top_module, "Top module",
        modules: Enum.map(pod_package_set.packages, fn p -> to_module(p) end)
      )
    )
  end

  def generate_crate(
        %PodPackageSet{} = pod_package_set,
        crate_name,
        target_path \\ nil
      )
      when is_atom(crate_name) do
    target_path = target_path || "/tmp/tmp/#{crate_name}"

    to_crate(pod_package_set, crate_name)
    |> CrateGenerator.generate_crate(target_path)
  end
end
