defmodule WorkReport.Report.Month do
  @moduledoc """
  Represents a month report in the work report.
  """

  alias WorkReport.Report.Day

  @names %{
    "January" => 1,
    "February" => 2,
    "March" => 3,
    "April" => 4,
    "May" => 5,
    "June" => 6,
    "July" => 7,
    "August" => 8,
    "September" => 9,
    "October" => 10,
    "November" => 11,
    "December" => 12
  }

  @type t :: %__MODULE__{
          name: String.t(),
          number: non_neg_integer(),
          days: [Day.t()]
        }

  defstruct [:name, :number, days: []]

  @spec new(String.t()) :: {:ok, t()} | {:error, String.t()}
  def new(name) when not is_map_key(@names, name), do: {:error, "Invalid month name: #{name}"}
  def new(name), do: {:ok, %__MODULE__{name: name, number: @names[name]}}

  @spec add_day(t(), Day.t()) :: t()
  def add_day(month, day), do: %{month | days: [day | month.days]}

  @spec days_count(t()) :: integer()
  def days_count(%__MODULE__{days: days}), do: Enum.count(days)

  @spec total_minutes(t()) :: integer()
  def total_minutes(%__MODULE__{days: days}), do: Enum.sum_by(days, &Day.total_minutes/1)

  @spec minutes_by_category(t()) :: %{String.t() => pos_integer()}
  def minutes_by_category(%__MODULE__{days: days}) do
    Enum.reduce(days, %{}, fn day, acc ->
      day
      |> Day.minutes_by_category()
      |> Map.merge(acc, fn _k, v1, v2 -> v1 + v2 end)
    end)
  end

  @spec stats(t()) :: map()
  def stats(month_report) do
    days_count = days_count(month_report)
    total_minutes = total_minutes(month_report)
    avg_minutes_by_day = if days_count > 0, do: total_minutes / days_count, else: 0

    %{
      total_minutes: total_minutes,
      days_count: days_count,
      avg_minutes_by_day: avg_minutes_by_day,
      minutes_by_category: minutes_by_category(month_report)
    }
  end
end
