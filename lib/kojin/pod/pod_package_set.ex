defmodule Kojin.Pod.PodPackageSet do

  @moduledoc """
  Models a collection of related packages which may refer to
  types with `dot notation` paths.
  """

  use TypedStruct

  alias Kojin.Pod.{PodPackage, PodPackageSet}

  @typedoc """
  Models a collection of related packages which may refer to
  types with `dot notation` paths.
  """
  typedstruct enforce: true do
    field(:packages, list(PodPackage.t()))
  end


  @doc """
  Creates a collection of related packages which may refer to
  types with `dot notation` paths.
  """
  def pod_package_set(packages) when is_list(packages) do
    %PodPackageSet{
      packages: packages
    }
  end

  def info(%PodPackageSet{} = pod_package_set) do
    IO.puts inspect(pod_package_set, pretty: true)
  end

end
