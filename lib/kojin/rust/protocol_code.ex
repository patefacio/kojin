defprotocol Kojin.Rust.ToCode do
  alias Kojin.Rust.{Struct, Trait, TraitImpl, TypeImpl, Fn}
  @spec to_code(Struct.t() | Trait.t() | TraitImpl.t() | TypeImpl.t() | Fn.t()) :: binary
  def to_code(type)
end
