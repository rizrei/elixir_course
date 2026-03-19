defmodule Caesar do
  # We consider only chars in range 32 - 126 as valid ascii chars
  # http://www.asciitable.com/
  @min_ascii_char 32
  @max_ascii_char 126
  @ascii_range_length @max_ascii_char - @min_ascii_char + 1

  @doc """
  Function shifts forward all characters in string. String could be double-quoted or single-quoted.

  ## Examples
  iex> Caesar.encode("Hello", 10)
  "Rovvy"
  iex> Caesar.encode('Hello', 5)
  'Mjqqt'
  """
  def encode(str, code), do: encode(str, code, [])

  defp encode([], code, acc), do: Enum.reverse(acc)
  defp encode([h | t], code, acc), do: encode(t, code, [h + code | acc])

  defp encode("", code, acc), do: acc |> Enum.reverse() |> List.to_string()
  defp encode(<<h::utf8, t::binary>>, code, acc), do: encode(t, code, [h + code | acc])

  @doc """
  Function shifts backward all characters in string. String could be double-quoted or single-quoted.

  ## Examples
  iex> Caesar.decode("Rovvy", 10)
  "Hello"
  iex> Caesar.decode('Mjqqt', 5)
  'Hello'
  """
  def decode(str, code), do: encode(str, -code)

  @doc ~S"""
  Function shifts forward all characters in string. String could be double-quoted or single-quoted.
  All characters should be in range 32-126, otherwise function raises RuntimeError with message "invalid ascii str"
  If result characters are out of valid range, than function wraps them to the beginning of the range.

  ## Examples
  iex> Caesar.encode_ascii('hello world', 15)
  'wt{{~/\'~\"{s'
  """
  def encode_ascii(str, code), do: encode_ascii(str, code, [])

  defp encode_ascii([], code, acc), do: Enum.reverse(acc)

  defp encode_ascii([h | _], _, _) when h not in @min_ascii_char..@max_ascii_char do
    raise "invalid ascii str"
  end

  defp encode_ascii([h | t], code, acc),
    do: encode_ascii(t, code, [encode_ascii_char(h, code) | acc])

  defp encode_ascii("", code, acc), do: acc |> Enum.reverse() |> List.to_string()

  defp encode_ascii(<<h::utf8, t::binary>>, _, _)
       when h not in @min_ascii_char..@max_ascii_char do
    raise "invalid ascii str"
  end

  defp encode_ascii(<<h::utf8, t::binary>>, code, acc),
    do: encode_ascii(t, code, [encode_ascii_char(h, code) | acc])

  defp encode_ascii_char(char, code) when char + code < @min_ascii_char do
    char + code + @ascii_range_length
  end

  defp encode_ascii_char(char, code) when char + code > @max_ascii_char do
    char + code - @ascii_range_length
  end

  defp encode_ascii_char(char, code) do
    char + code
  end

  @doc ~S"""
  Function shifts backward all characters in string. String could be double-quoted or single-quoted.
  All characters should be in range 32-126, otherwise function raises RuntimeError with message "invalid ascii str"
  If result characters are out of valid range, than function wraps them to the end of the range.

  ## Examples
  iex> Caesar.decode_ascii('wt{{~/\'~\"{s', 15)
  'hello world'
  """
  def decode_ascii(str, code), do: encode_ascii(str, -code)
end
