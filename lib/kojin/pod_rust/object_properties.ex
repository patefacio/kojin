defmodule Kojin.PodRust.ObjectProperties do
  @moduledoc false

  require Logger
  alias Kojin.Pod.{PodObject, PodField}
  import Kojin.Rust

  @doc "Add the list of derivables to the pod_object."
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

  @doc "Remove the list of derivables to the pod_object."
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
  def rust_plus_derivables(%PodObject{} = pod_object, derivables) when is_list(derivables) do
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
  def rust_minus_derivables(%PodObject{} = pod_object, derivables) when is_list(derivables) do
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
        fn _current_derivables ->
          derivables
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

  def rust_field_visibility(%PodObject{} = pod_object, field_visibility) do
    if(is_valid_visibility(field_visibility)) do
      put_in(
        pod_object,
        [
          Access.key(:properties, %{}),
          Access.key(:rust, %{}),
          Access.key(:field_visibility, nil)
        ],
        field_visibility
      )
    end
  end

  def rust_field_access(%PodObject{} = pod_object, field_access) do
    put_in(
      pod_object,
      [
        Access.key(:properties, %{}),
        Access.key(:rust, %{}),
        Access.key(:field_access, nil)
      ],
      field_access
    )
  end

  @doc """
  Set the fields to `pub(crate)` visibility and provide `read_only` access
  """
  def rust_hide_fields(%PodObject{} = pod_object) do
    pod_object
    |> rust_field_visibility(:pub_crate)
    |> rust_field_access(:ro)
  end

  @doc """
  Set the `with_new?` flag on the struct to include generated `::new()`
  """
  def rust_with_new(%PodObject{} = pod_object) do
    put_in(
      pod_object,
      [
        Access.key(:properties, %{}),
        Access.key(:rust, %{}),
        Access.key(:with_new?, true)
      ],
      true
    )
  end

  def rust_box_field(%PodField{} = pod_field) do
    put_in(
      pod_field,
      [
        Access.key(:properties, %{}),
        Access.key(:rust, %{}),
        Access.key(:boxed, true)
      ],
      true
    )
  end
end
