defmodule IndexOutOfBoundsError do
  @moduledoc """
  Custom exception for index out of bounds error
   - has a default message "Index out of bounds"
  """

  @enforce_keys [:list, :index]
  defexception [:list, :index]

  @impl true
  def exception({list, index}) do
    %__MODULE__{list: list, index: index}
  end

  @impl true
  def message(%__MODULE__{list: list, index: index}) do
    "index #{index} is out of bounds [0-#{length(list)})"
  end
end

defmodule Homework do
  @moduledoc """
  Homework module with functions that use custom exceptions
   - get_from_list!/2 takes a list and an index and returns the element at the given index or raises IndexOutOfBoundsError if the index is out of bounds
   - get_from_list/2 takes a list and an index and returns {:ok, element} tuple if the index is valid or {:error, message} tuple if the index is out of bounds
   - get_many_from_list!/2 takes a list and a list of indices and returns a list of elements at the given indices or raises IndexOutOfBoundsError if any of the indices is out of bounds
   - get_many_from_list/2 takes a list and a list of indices and returns {:ok, elements} tuple if all indices are valid or {:error, message} tuple if any of the indices is out of bounds
   - all functions should handle negative indices as well (e.g. -1 means the last element, -2 means the second to last element, etc.)
  """

  @spec get_from_list!([any()], integer()) :: any() | no_return()
  def get_from_list!(list, index) do
    case do_get_from_list(list, index) do
      {:ok, list} -> list
      {:error, error} -> raise error
    end
  end

  def get_from_list(list, index) do
    case do_get_from_list(list, index) do
      {:ok, list} -> {:ok, list}
      {:error, error} -> {:error, IndexOutOfBoundsError.message(error)}
    end
  end

  @spec get_many_from_list!([any()], [integer()]) :: [any()] | no_return()
  def get_many_from_list!(list, indices) do
    case do_get_many_from_list(list, indices) do
      {:ok, list} -> list
      {:error, error} -> raise error
    end
  end

  @spec get_many_from_list([any()], [integer()]) :: {:ok, [any()]} | {:error, String.t()}
  def get_many_from_list(list, indices) do
    case do_get_many_from_list(list, indices) do
      {:ok, list} -> {:ok, list}
      {:error, error} -> {:error, IndexOutOfBoundsError.message(error)}
    end
  end

  defp do_get_from_list(list, index) when index < 0 or index >= length(list) do
    {:error, IndexOutOfBoundsError.exception({list, index})}
  end

  defp do_get_from_list(list, index), do: {:ok, Enum.at(list, index)}

  defp do_get_many_from_list(list, indices) do
    dict = Stream.iterate(0, &(&1 + 1)) |> Enum.zip(list) |> Enum.into(%{})

    indices
    |> Enum.reverse()
    |> Enum.reduce_while({:ok, []}, fn
      i, {:ok, list} when is_map_key(dict, i) -> {:cont, {:ok, [dict[i] | list]}}
      i, _acc -> {:halt, {:error, IndexOutOfBoundsError.exception({Map.values(dict), i})}}
    end)
  end
end
