defmodule ModuleTest do
  use ExUnit.Case

  import Kojin.Rust.{Module}

  test "module composition" do
    module(:top, "Top module",
      modules: [
        module(:middle, "Middle module",
          modules: [
            module(:inner, "Innermost module")
          ]
        )
      ]
    )
  end
end
