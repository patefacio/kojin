defmodule Kojin.PodRust.ObjectProperties do
  @moduledoc false

  require Logger
  alias Kojin.Pod.PodObject
  import Kojin.Rust

  def add_derivables(%PodObject{} = pod_object, derivables) when is_list(derivables) do
    if(valid_derivables?(derivables)) do
      update_in(
        pod_object,
        [
          Access.key(:properties, %{}),
          Access.key(:rust, %{}),
          Access.key(:derivables, [])
        ],
        fn current_derivables ->
          (derivables ++ current_derivables)
          |> MapSet.new()
          |> Enum.to_list()
          |> Enum.sort()
        end
      )
    else
      Logger.warn("Ignoring pod object properties #{inspect(derivables)}")
      pod_object
    end
  end
end
