defmodule Kojin.Rust.Bounds do
  use TypedStruct
  alias Kojin.Rust.Bounds

  typedstruct do
    field(:lifetimes, list(String.t()))
    field(:traits, list(String.t()))
  end

  def empty?(bounds) do
    Enum.empty?(bounds.lifetimes) && Enum.empty?(bounds.traits)
  end

  defp add_binding(current = %{:lifetimes => lifetimes}, bound) when is_atom(bound) do
    Map.put(current, :lifetimes, [lifetime(bound) | lifetimes])
  end

  defp add_binding(current = %{:traits => traits}, bound) when is_binary(bound) do
    Map.put(current, :traits, [bound | traits])
  end

  @doc """
  Validates lifetime, ensuring it consists only of word characters
  """
  defp lifetime(lt) when is_atom(lt) do
    true = Regex.match?(~r/^\w+$/, "#{lt}")
    lt
  end

  defp lifetime(lt) when is_binary(lt), do: lifetime(String.to_atom(lt))

  @doc """
  When specifying a list of bounds, use atoms for the lifetimes
  and strings for the trait bounds.

  When specifying as hash {lifetimes:..., traits:...}
  atoms or strings work.
  """
  def bounds(bounds) when is_list(bounds) do
    opts =
      bounds
      |> Enum.reduce(%{lifetimes: [], traits: []}, fn bound, acc ->
        add_binding(acc, bound)
      end)

    struct(Bounds, %{
      lifetimes: Enum.reverse(opts.lifetimes),
      traits: Enum.reverse(opts.traits)
    })
  end

  def bounds(bounds) when is_map(bounds) do
    lifetimes =
      bounds
      |> Map.get(:lifetimes, [])
      |> Enum.map(fn lt -> lifetime(lt) end)

    traits =
      bounds
      |> Map.get(:traits, [])
      |> Enum.map(fn lt -> "#{lt}" end)

    %Bounds{
      lifetimes: lifetimes,
      traits: traits
    }
  end

  def code(bounds) do
    [
      [
        bounds.lifetimes
        |> Enum.map(fn lifetime -> "'#{lifetime}" end)
      ],
      [
        bounds.traits
      ]
    ]
    |> List.flatten()
    |> Enum.join(" + ")
  end

  defimpl String.Chars do
    def to_string(bounds), do: Bounds.code(bounds)
  end
end
