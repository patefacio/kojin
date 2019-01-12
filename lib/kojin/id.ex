defmodule Kojin.Id do
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

  def cap_camel(words) when is_list(words) do
    words
    |> Enum.map(&String.downcase/1)
    |> Enum.join("_")
  end

  def snake(words) when is_list(words) do
    words
    |> Enum.map(&String.downcase/1)
    |> Enum.join("_")
  end

  def shout(words) when is_list(words) do
    words
    |> Enum.map(&String.upcase/1)
    |> Enum.join("_")
  end

  def emacs(words) when is_list(words) do
    words
    |> Enum.map(&String.downcase/1)
    |> Enum.join("-")
  end

  @snake_re ~r{^[a-z]+[a-z\d]*(?:_[a-z\d]+)*$}

  def is_snake(text) when is_binary(text) do
    Regex.match?(@snake_re, text)
  end

  # indicates char transition from lower to upper
  @char_transition_re ~r/([^\p{Lu}])(\p{Lu})/

  @word_divider_re ~r/[_-]/

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
    end
  end

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
