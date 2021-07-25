defprotocol Kojin.Rust.ToCode do
  @spec to_code(any) :: binary
  def to_code(type)
end
