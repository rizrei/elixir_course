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
  def get_from_list!(list, index) when index < 0 or index >= length(list) do
    raise IndexOutOfBoundsError, {list, index}
  end

  def get_from_list!(list, index), do: Enum.at(list, index)

  @spec get_from_list([any()], integer()) :: {:ok, any()} | {:error, String.t()}
  def get_from_list(list, index) when index < 0 or index >= length(list) do
    {:error, "index #{index} is out of bounds [0-#{length(list)})"}
  end

  def get_from_list(list, index), do: {:ok, Enum.at(list, index)}

  @spec get_many_from_list!([any()], [integer()]) :: [any()] | no_return()
  def get_many_from_list!(list, indices) do
    len = length(list)

    case Enum.filter(indices, fn i -> i < 0 or i >= len end) do
      [] -> Enum.map(indices, fn i -> Enum.at(list, i) end)
      [index | _] -> raise IndexOutOfBoundsError, {list, index}
    end
  end

  @spec get_many_from_list([any()], [integer()]) :: {:ok, [any()]} | {:error, String.t()}
  def get_many_from_list(list, indices) do
    len = length(list)

    case Enum.filter(indices, fn i -> i < 0 or i >= len end) do
      [] -> {:ok, Enum.map(indices, fn i -> Enum.at(list, i) end)}
      [index | _] -> {:error, "index #{index} is out of bounds [0-#{length(list)})"}
    end
  end
end
