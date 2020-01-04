defmodule Kojin.PodRust.EnumProperties do
  @moduledoc false

  require Logger
  alias Kojin.Pod.PodEnum
  import Kojin.Rust

  def snake_conversions(%PodEnum{} = pod_enum, snake_conversions \\ true)
      when is_boolean(snake_conversions) do
    put_in(
      pod_enum,
      [
        Access.key(:properties, %{}),
        Access.key(:rust, %{}),
        :has_snake_conversions
      ],
      snake_conversions
    )
  end
end
