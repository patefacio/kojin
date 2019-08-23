defmodule Kojin.Id do
  @moduledoc """
  Functions for dealing consistently wtih the casing of identifiers.
  """

  # String dividers for snake and emacs case
  @word_divider_re ~r/[_-]/

  # Indicates char transition from lower to upper
  @char_transition_re ~r/([^\p{Lu}])(\p{Lu})/

  # Indicates string is in snake case
  @snake_re ~r{^[a-z]+[a-z\d]*(?:_[a-z\d]+)*$}

  @doc """
  Split text into list of words, where word boundaries are identified as "_"
  for snake case or case transition for camel case.
  """
  def words(text) when is_binary(text) do
    cond do
      Regex.run(@word_divider_re, text) ->
        String.downcase(text) |> String.split(@word_divider_re)

      Regex.run(@char_transition_re, text) ->
        words(
          Regex.replace(@char_transition_re, text, fn _, lower_char, upper_char ->
            String.downcase("#{lower_char}_#{upper_char}")
          end)
        )

      true ->
        [text]
    end
  end

  def words(id) do
    words(to_string(id))
  end

  @doc """
  Convert to camel case.

  ## Examples

      iex> Kojin.Id.camel(:foo_bar_goo)
      "fooBarGoo"

      iex> Kojin.Id.camel("FooBarGoo")
      "fooBarGoo"

      iex> Kojin.Id.camel("fooBarGoo")
      "fooBarGoo"

  """
  def camel(words) when is_list(words) do
    words
    |> Enum.take(1)
    |> Enum.map(&String.downcase/1)
    |> Enum.concat(
      words
      |> Enum.drop(1)
      |> Enum.map(&String.capitalize/1)
    )
    |> Enum.join("")
  end

  def camel(text) when is_binary(text), do: camel(words(text))
  def camel(text) when is_atom(text), do: camel(Atom.to_string(text))

  @doc """
  Convert to cap camel case.

  ## Examples

      iex> Kojin.Id.cap_camel(:foo_bar_goo)
      "FooBarGoo"

      iex> Kojin.Id.cap_camel("FooBarGoo")
      "FooBarGoo"

      iex> Kojin.Id.cap_camel("fooBarGoo")
      "FooBarGoo"

  """
  def cap_camel(words) when is_list(words) do
    words
    |> Enum.map(&String.capitalize/1)
    |> Enum.join("")
  end

  def cap_camel(text) when is_binary(text), do: cap_camel(words(text))
  def cap_camel(text) when is_atom(text), do: cap_camel(Atom.to_string(text))

  @doc """
  Convert to snake case.

  ## Examples

      iex> Kojin.Id.snake(:foo_bar_goo)
      "foo_bar_goo"

      iex> Kojin.Id.snake("FooBarGoo")
      "foo_bar_goo"

      iex> Kojin.Id.snake("fooBarGoo")
      "foo_bar_goo"

  """
  def snake(words) when is_list(words) do
    words
    |> Enum.map(&String.downcase/1)
    |> Enum.join("_")
  end

  def snake(text) when is_binary(text), do: snake(words(text))
  def snake(text) when is_atom(text), do: snake(Atom.to_string(text))

  @doc """
  Convert to shout case.

  ## Examples

      iex> Kojin.Id.shout(:foo_bar_goo)
      "FOO_BAR_GOO"

      iex> Kojin.Id.shout("FooBarGoo")
      "FOO_BAR_GOO"

      iex> Kojin.Id.shout("fooBarGoo")
      "FOO_BAR_GOO"

  """
  def shout(words) when is_list(words) do
    words
    |> Enum.map(&String.upcase/1)
    |> Enum.join("_")
  end

  def shout(text) do
    shout(words(text))
  end

  @doc """
  Convert to emacs case.

  ## Examples

      iex> Kojin.Id.emacs(:foo_bar_goo)
      "foo-bar-goo"

      iex> Kojin.Id.emacs("FooBarGoo")
      "foo-bar-goo"

      iex> Kojin.Id.emacs("fooBarGoo")
      "foo-bar-goo"

  """
  def emacs(words) when is_list(words) do
    words
    |> Enum.map(&String.downcase/1)
    |> Enum.join("-")
  end

  def emacs(text) do
    emacs(words(text))
  end

  @doc """
  Returns true if string is snake case.

  ## Examples

      iex> Kojin.Id.is_snake("foo_bar_goo")
      true

      iex> Kojin.Id.is_snake("FooBarGoo")
      false

      iex> Kojin.Id.is_snake("foo Bar Goo")
      false

  """
  def is_snake(text) when is_binary(text) do
    Regex.match?(@snake_re, text)
  end

  @doc """
  Returns id (snake case) of text.

  ## Examples

  From snake case

      iex> Kojin.Id.id("foo_bar_goo")
      "foo_bar_goo"

  From cap camel case

      iex> Kojin.Id.id("FooBarGoo")
      "foo_bar_goo"

  From camel case

      iex> Kojin.Id.id("fooBarGoo")
      "foo_bar_goo"

  """
  def id(text) when is_binary(text) do
    cond do
      is_snake(text) ->
        text

      true ->
        words(text)
        |> Enum.join("_")
    end
  end
end
