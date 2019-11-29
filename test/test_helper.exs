ExUnit.start()

defmodule TestHelper do
  use ExUnit.Case
  import Kojin
  import Kojin.Utils
  alias String.Chars

  #######################################################################################
  # This allows tests to access module with sample data
  # https://stackoverflow.com/questions/30652439/importing-test-code-in-elixir-unit-test
  #######################################################################################
  Code.load_file("test/sample_data/pod_samples.ex")

  @doc "
  Remove whitespace from `under_test` and `expected`,
  compare them and if false run standard assert.

  The idea is to show the `under_test` as courtesy when
  there is a failure, along with the output from the assert.
  "
  def dark_compare(under_test, expected) do
    under_test_str = Chars.to_string(under_test) |> dark_matter()
    expected_str = Chars.to_string(expected) |> dark_matter()

    if(under_test_str != expected_str) do
      "-----------\nFailed `dark_compare` with `under_test`:\n#{under_test}\n--------\n"
      |> indent_block
      |> IO.puts()

      assert under_test_str == expected_str
    end
  end
end
