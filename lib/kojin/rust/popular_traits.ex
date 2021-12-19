import Kojin.Rust.{Fn, Parm, Trait, Type, Use}

defmodule Kojin.Rust.PopularTraits do
  @doc """
  Returns the trait definition for `std::fmt::Debug` trait.


  ## Examples

    iex> import Kojin.Rust.PopularTraits
    ...> default()
    ...> |> String.Chars.to_string()
    ...> |> String.contains?("fn default() -> Self;")
    true
  """
  def default() do
    trait(:default, "Trait to provide default value", [
      fun(
        :default,
        "Function to provide default value of type",
        [],
        return: "Self",
        return_doc: "Returns the default for the type"
      )
    ])
  end

  @spec debug :: Kojin.Rust.Trait.t()
  @doc """
  Returns the trait definition for `std::fmt::Debug` trait.


  ## Examples

    iex> import Kojin.Rust.PopularTraits
    ...> debug()
    ...> |> String.Chars.to_string()
    ...> |> String.contains?("fn fmt(self: & Self, f: & mut Formatter<'_>) -> std::fmt::Result;")
    true
  """
  def debug() do
    trait(
      :debug,
      "Trait to provide debug output",
      [
        fun(
          :fmt,
          """
          Debug should format the output in a programmer-facing, debugging context.

          Generally speaking, you should just derive a Debug implementation.

          When used with the alternate format specifier #?, the output is pretty-printed
          """,
          [
            :self_ref,
            parm(:f, mref("Formatter<'_>"), "Formatter")
          ],
          return: {"std::fmt::Result", "The formatted representation of object"}
        )
      ],
      path: "std::fmt",
      uses: [
        use_("std::fmt::Debug"),
        use_("std::fmt::Formatter")
      ]
    )
  end
end
