defmodule PodTest do
  use ExUnit.Case
  alias Kojin.PodObject
  alias Kojin.PodField
  import Kojin.PodField

  import ExUnit.CaptureIO

  test "pod object" do
    p1 = %PodObject{name: "foo", doc: "Goo"}
    p2 = %PodObject{name: "foo", doc: "Good"}

    # assert (p1 == p2)

    z = %{p1 => "p1", p2 => "p2"}

    IO.puts(inspect(z, pretty: true))

    IO.puts(inspect(Map.put(z, p1, "P1"), pretty: true))

    IO.puts(
      inspect(
        %PodObject{
          name: 3,
          doc: "bam",
          fields: [
            pod_field(:foo, "doc string", type: :Int32),
            pod_field(:foo_bar_oo, "Bam", type: :Int64, is_optional: true)
          ]
        },
        pretty: true
      )
    )

    IO.puts(
      ~s(Pod Ojbect:\n#{
        inspect(
          %PodObject{
            name: "Foody",
            doc: "Goo",
            fields: []
          },
          pretty: true
        )
      })
    )
  end

  test "pod field" do
    pf = pod_field(:foo_bar, "sample foo bar field", is_optional: true)
    IO.puts(pf)
  end
end
