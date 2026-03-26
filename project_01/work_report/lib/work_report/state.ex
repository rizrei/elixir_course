defmodule WorkReport.State do
  @moduledoc """
  State struct for parsing work report files.

  m - target month number
  d - target day number
  e - last parsed entity (Month, Day, Task or error)
  m_number - target month number
  d_number - target day number
  file_path - path to the report file
  """

  alias WorkReport.Parser
  alias WorkReport.Report.{Day, Month, Task}

  @type entity() :: Month.t() | Day.t() | Task.t()
  @type t :: %__MODULE__{
          m_number: 1..12,
          d_number: 1..31,
          m: Month.t() | nil,
          d: Day.t() | nil,
          file_path: String.t(),
          e: entity() | nil,
          error: {:error, String.t()} | nil
        }

  @enforce_keys [:m_number, :d_number, :file_path]
  defstruct [
    :file_path,
    :m_number,
    :d_number,
    m: nil,
    d: nil,
    e: nil,
    error: nil
  ]

  @spec new(String.t(), keyword()) :: t()
  def new(file_path, keyword) do
    %__MODULE__{
      file_path: file_path,
      m_number: Keyword.get(keyword, :month, Date.utc_today().month),
      d_number: Keyword.get(keyword, :day, Date.utc_today().day)
    }
  end

  @spec validate(t()) :: :ok | {:error, String.t()}
  def validate(%__MODULE__{m_number: number}) when number not in 1..12 do
    {:error, "Month must be between 1 and 12, got: #{number}"}
  end

  def validate(%__MODULE__{d_number: number}) when number not in 1..31 do
    {:error, "Day must be between 1 and 31, got: #{number}"}
  end

  def validate(%__MODULE__{}), do: :ok

  @spec parse(t()) :: {:ok, Month.t(), Day.t()} | {:error, String.t()}
  def parse(state) do
    File.stream!(state.file_path)
    |> Stream.map(&String.trim/1)
    |> Stream.reject(&(&1 == ""))
    |> Enum.reduce_while(state, fn str, acc -> acc |> parse_str(str) |> dispatch() end)
    |> result()
  rescue
    e in File.Error -> {:error, "Failed to read file: #{e.path}"}
  end

  @spec parse_str(t(), String.t()) :: t()
  defp parse_str(state, str) do
    case Parser.parse(str) do
      {:ok, entity} -> %{state | e: entity}
      {:error, error} -> %{state | error: error}
    end
  end

  @spec dispatch(t()) :: {:cont, t()} | {:halt, t()}
  defp dispatch(%{e: %Month{number: number} = month, m: nil, m_number: number} = state) do
    {:cont, %{state | m: month}}
  end

  defp dispatch(%{e: %Month{}, m: %Month{number: number}, m_number: number} = state) do
    {:halt, state}
  end

  defp dispatch(%{e: %Day{number: number} = day, m: %Month{} = month, d_number: number} = state) do
    {:cont, %{state | d: day, m: %{month | days: [day | month.days]}}}
  end

  defp dispatch(%{e: %Day{} = day, m: %Month{} = month} = state) do
    {:cont, %{state | m: %{month | days: [day | month.days]}}}
  end

  defp dispatch(%{e: %Task{} = task, d: day, m: %Month{days: [day | days]} = month} = state) do
    day = Day.add_task(day, task)
    {:cont, %{state | d: day, m: %{month | days: [day | days]}}}
  end

  defp dispatch(%{e: %Task{} = task, m: %Month{days: [day | days]} = month} = state) do
    day = Day.add_task(day, task)
    {:cont, %{state | m: %{month | days: [day | days]}}}
  end

  defp dispatch(%{error: error} = state) when error != nil, do: {:halt, state}
  defp dispatch(state), do: {:cont, state}

  @spec result(t()) :: {:ok, Month.t(), Day.t()} | {:error, String.t()}
  defp result(%__MODULE__{m: %Month{} = m, d: %Day{} = d, error: nil}), do: {:ok, m, d}
  defp result(%__MODULE__{error: error}) when error != nil, do: {:error, error}
  defp result(%__MODULE__{m: nil} = state), do: {:error, "Month #{state.m_number} is not found"}

  defp result(%__MODULE__{d: nil} = state),
    do: {:error, "Day #{state.d_number} is not found in month #{state.m_number}"}
end
