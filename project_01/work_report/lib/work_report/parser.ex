defmodule WorkReport.Parser do
  @moduledoc """
  Parses lines of the report file and extracts entities: months, days and tasks.
  """

  alias WorkReport.Report.{Month, Day, Task}

  @month_regex ~r/# (?<month>[A-Za-z]+)/
  @day_regex ~r/## (?<day>\d+) (?<name>.+)/
  @task_regex ~r/
    ^\[?(?<category>\w+)\]?\s+
    (?<description>.+?)\s*-\s*
    (?=(?:\d+h|\d+m))
    ((?<hours>\d+)h)?\s*
    ((?<minutes>\d+)m)?$/x

  @doc """
  Parses a single line and returns parsed entity or error.

  ## Examples

      iex> WorkReport.Parser.parse("# January")
      {:ok, %Month{name: "January", number: 1, days: []}}

      iex> WorkReport.Parser.parse("## 1 Monday")
      {:ok, %Day{number: 1, name: "Monday", next_task_position: 1, tasks: []}}

      iex> WorkReport.Parser.parse("[DEV] Fix bug - 2h 30m")
      {:ok, %Task{category: "DEV", description: "Fix bug", minutes: 150, position: nil}}
  """
  @spec parse(String.t()) :: {:ok, Month.t() | Day.t() | Task.t()} | {:error, String.t()}
  def parse(str) do
    cond do
      valid_month_string?(str) -> build_month(str)
      valid_day_string?(str) -> build_day(str)
      valid_task_string?(str) -> build_task(str)
      true -> invalid_line(str)
    end
  end

  defp valid_month_string?(str), do: Regex.match?(@month_regex, str)
  defp valid_day_string?(str), do: Regex.match?(@day_regex, str)
  defp valid_task_string?(str), do: Regex.match?(@task_regex, str)

  defp build_month(str) do
    with %{"month" => month} <- Regex.named_captures(@month_regex, str),
         {:ok, _} = result <- Month.new(month) do
      result
    else
      {:error, reason} -> invalid_line(str, reason)
      _ -> invalid_line(str)
    end
  end

  defp build_day(str) do
    case Regex.named_captures(@day_regex, str) do
      %{"day" => day, "name" => name} -> {:ok, %Day{name: name, number: parse_integer(day)}}
      _ -> invalid_line(str)
    end
  end

  defp build_task(str) do
    with %{} = captures <- Regex.named_captures(@task_regex, str),
         %{} = attributes <- build_task_attributes(captures),
         {:ok, _} = result <- Task.new(attributes) do
      result
    else
      {:error, reason} -> invalid_line(str, reason)
      _ -> invalid_line(str)
    end
  end

  defp build_task_attributes(captures) do
    captures
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
    |> Map.update!(:hours, &parse_integer/1)
    |> Map.update!(:minutes, &parse_integer/1)
    |> then(&%{&1 | minutes: &1.minutes + &1.hours * 60})
    |> Map.take([:category, :description, :minutes])
  end

  defp parse_integer(""), do: 0
  defp parse_integer(str), do: String.to_integer(str)

  defp invalid_line(str, reason \\ "")
  defp invalid_line(str, ""), do: {:error, "Invalid line format: #{str}"}
  defp invalid_line(str, reason), do: {:error, "Invalid line format: #{str}. #{reason}"}
end
