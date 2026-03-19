defmodule Trim do
  # We only trim space character
  def is_space(char), do: char == 32

  @doc """
  Function trim spaces in the beginning and in the end of the string.
  It accepts both single-quoted and double-quoted strings.

  ## Examples
  iex> Trim.trim('   hello there   ')
  'hello there'
  iex> Trim.trim("  Привет   мир  ")
  "Привет   мир"
  """
  def trim(str) when is_list(str) do
    # We iterate string 4 times here
    str
    |> trim_left
    |> Enum.reverse()
    |> trim_left
    |> Enum.reverse()
  end

  def trim(str) when is_binary(str) do
    # And yet 2 more iterations here
    str
    |> to_charlist
    |> trim
    |> to_string
  end

  defp trim_left([]), do: []

  defp trim_left([head | tail] = str) do
    if is_space(head) do
      trim_left(tail)
    else
      str
    end
  end

  def effective_trim(str) when is_list(str) do
    do_trim(str, [], :left)
  end

  def effective_trim(str) when is_binary(str) do
    str
    |> to_charlist()
    |> effective_trim()
    |> to_string()
  end

  def do_trim([], acc, :right), do: acc
  def do_trim([], acc, :left), do: do_trim(acc, [], :right)
  def do_trim([32 | t], [], mode), do: do_trim(t, [], mode)
  def do_trim([h | t], acc, mode), do: do_trim(t, [h | acc], mode)
end
