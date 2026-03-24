defmodule WorkReport do
  @moduledoc """
  Analyze report file and gather work statistics
  """

  alias WorkReport.{Formatter}
  alias WorkReport.Report.{Month, Day, Task}
  alias WorkReport.Parser

  @name "Work Report"
  @version "1.0.0"

  @spec main([String.t()]) :: :ok
  def main(args) do
    case OptionParser.parse(args, options()) do
      {[help: true], [], []} -> help()
      {[version: true], [], []} -> version()
      {params, [file_path], []} -> do_report(file_path, Map.new(params))
      _ -> help()
    end
  end

  def parse_file(file_path, target_month_number, target_day_number) do
    state = %{
      target_month_number: target_month_number,
      target_month: nil,
      target_day_number: target_day_number,
      target_day: nil,
      entity: nil,
      error: nil
    }

    File.stream!(file_path)
    |> Stream.map(&String.trim/1)
    |> Stream.reject(&(&1 == ""))
    |> Enum.reduce_while(state, &reducer/2)
    |> case do
      %{target_day: %Day{} = day, target_month: %Month{} = month} ->
        {:ok, month, day}

      %{target_month: nil} ->
        {:error, "Month #{target_month_number} is not found"}

      %{target_day: nil} ->
        {:error, "Day #{target_day_number} is not found in month #{target_month_number}"}

      %{error: error} when error != nil ->
        {:error, error}

      _ ->
        {:error, :report_not_found}
    end
  end

  def reducer(str, acc) do
    acc
    |> Map.put(:entity, Parser.parse(str))
    |> case do
      %{entity: %Month{number: number} = month, target_month: nil, target_month_number: number} ->
        {:cont, %{acc | target_month: month}}

      %{
        entity: %Day{number: number} = day,
        target_month: %Month{} = month,
        target_day_number: number
      } ->
        {:cont, %{acc | target_day: day, target_month: %{month | days: [day | month.days]}}}

      %{entity: %Day{} = day, target_month: %Month{} = month} ->
        {:cont, %{acc | target_month: %{month | days: [day | month.days]}}}

      %{entity: %Task{} = task, target_day: day, target_month: %Month{days: [day | days]} = month} ->
        day = Day.add_task(day, task)
        {:cont, %{acc | target_day: day, target_month: %{month | days: [day | days]}}}

      %{entity: %Task{} = task, target_month: %Month{days: [day | days]} = month} ->
        day = Day.add_task(day, task)
        {:cont, %{acc | target_month: %{month | days: [day | days]}}}

      %{entity: error} when is_atom(error) ->
        {:halt, %{acc | error: error}}

      %{entity: %Month{}, target_month: %Month{number: number}, target_month_number: number} ->
        {:halt, acc}

      _ ->
        {:cont, acc}
    end
  end

  defp do_report(file_path, params) do
    month = Map.get(params, :month, Date.utc_today().month)
    day = Map.get(params, :day, Date.utc_today().day)

    with :ok <- validate_month(month),
         {:ok, month, day} <- parse_file(file_path, month, day) do
      day |> Formatter.format_day_report() |> IO.puts()
      month |> Formatter.format_month_report() |> IO.puts()
    else
      {:error, reason} -> IO.puts(reason)
    end
  end

  defp validate_month(month) when month >= 1 and month <= 12, do: :ok
  defp validate_month(month), do: {:error, "Month must be between 1 and 12, got: #{month}"}

  defp help() do
    IO.puts("""
    USAGE:
        work_report [OPTIONS] <path/to/report.md>
    OPTIONS:
        -m, --month <M>  Show report for month (int), current month by default
        -d, --day <D>    Show report for day (int), current day by default
        -v, --version    Show version
        -h, --help       Show this help message
    """)
  end

  defp version(), do: IO.puts(@name <> " v" <> @version)

  defp options do
    [
      strict: [day: :integer, month: :integer, version: :boolean, help: :boolean],
      aliases: [d: :day, m: :month, v: :version, h: :help]
    ]
  end
end
