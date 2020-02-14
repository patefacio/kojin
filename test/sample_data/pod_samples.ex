defmodule PodSamples do
  import Kojin.Pod.{PodObject, PodArray, PodTypeRef, PodPackage}

  @pet pod_object(
         :pet,
         "Pet object from open api pet store sample",
         [
           [:id, "Id of the pet", :int64],
           [:name, "Name of the pet", :string],
           [:tag, "An optional tag identifier", [type: :string, optional?: true]],
           [:last_vaccination, "Sample UDT", [type: pod_type_ref(:vaccination), optional?: true]],
           [:toys, "The pets toys", [type: array_of(:toy)]]
         ]
       )

  def sample_object(), do: @pet

  @pet_package pod_package(:pet_store, "Pet store pod package", pod_objects: [@pet])

  def sample_package(), do: @pet_package
end
