defmodule Kojin.PodRust.ObjectProperties do
  @moduledoc false

  require Logger
  alias Kojin.Pod.PodObject
  import Kojin.Rust

  @doc """
  Add the list of derivables to the pod_object.
  """
  def add_rust_derivables(%PodObject{} = pod_object, derivables) when is_list(derivables) do
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
      Logger.warn("Ignoring add of pod object derivable properties #{inspect(derivables)}")
      pod_object
    end
  end

  @doc """
  Remove the list of derivables to the pod_object.
  """
  def remove_rust_derivables(%PodObject{} = pod_object, derivables) when is_list(derivables) do
    if(valid_derivables?(derivables)) do
      update_in(
        pod_object,
        [
          Access.key(:properties, %{}),
          Access.key(:rust, %{}),
          Access.key(:derivables, [])
        ],
        fn current_derivables ->
          (current_derivables -- derivables)
          |> MapSet.new()
          |> Enum.to_list()
          |> Enum.sort()
        end
      )
    else
      Logger.warn("Ignoring removal of pod object derivable properties #{inspect(derivables)}")
      pod_object
    end
  end

  @doc """
  Return pod_object with standard derivables plus `derivables`.
  """
  def plus_rust_derivables(%PodObject{} = pod_object, derivables) when is_list(derivables) do
    if(valid_derivables?(derivables)) do
      pod_object
      |> add_rust_derivables(struct_common_derivables() ++ derivables)
    else
      Logger.warn("Ignoring with derivable invalid derivables #{inspect(derivables)}")
      pod_object
    end
  end

  @doc """
  Return pod_object with standard derivables minus `derivables`.
  """
  def minus_rust_derivables(%PodObject{} = pod_object, derivables) when is_list(derivables) do
    if(valid_derivables?(derivables)) do
      pod_object
      |> add_rust_derivables(struct_common_derivables())
      |> remove_rust_derivables(derivables)
    else
      Logger.warn("Ignoring without derivable invalid derivables #{inspect(derivables)}")
      pod_object
    end
  end

  @doc """
  Return pod_object with the set of `derivables`.
  """
  def with_rust_derivables(%PodObject{} = pod_object, derivables) when is_list(derivables) do
    if(valid_derivables?(derivables)) do
      update_in(
        pod_object,
        [
          Access.key(:properties, %{}),
          Access.key(:rust, %{}),
          Access.key(:derivables, [])
        ],
        fn _current_derivables -> derivables
          |> MapSet.new()
          |> Enum.to_list()
          |> Enum.sort()
        end
      )
    else
      Logger.warn("Ignoring with rust derivable invalid derivables #{inspect(derivables)}")
      pod_object
    end
  end

end
