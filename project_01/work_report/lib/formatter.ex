defmodule WorkReport.Formatter do
  alias WorkReport.Report.{Day, Month, Task}

  @spec format_time(number()) :: String.t()
  def format_time(0), do: "0"

  def format_time(minutes) when is_float(minutes), do: minutes |> trunc() |> format_time()

  def format_time(minutes) when minutes > 0 and minutes < 60, do: "#{minutes}m"

  def format_time(minutes) when minutes >= 60 do
    hours = div(minutes, 60)
    remaining = rem(minutes, 60)

    if remaining == 0, do: "#{hours}h", else: "#{hours}h #{remaining}m"
  end

  def format_day_report(%Day{number: number, name: name, tasks: tasks} = day) do
    tasks_str =
      tasks
      |> Enum.sort_by(& &1.position)
      |> Enum.map_join("\n", fn task ->
        " - #{task.category}: #{task.description} - #{format_time(task.minutes)}"
      end)

    """
    Day: #{number} #{name}
    #{tasks_str}
       Total: #{day |> Day.total_minutes() |> format_time()}
    """
  end

  def format_month_report(month_report) do
    %{
      total_minutes: total_minutes,
      days_count: days_count,
      avg_minutes_by_day: avg_minutes_by_day,
      minutes_by_category: minutes_by_category
    } = Month.stats(month_report)

    categories_str =
      Task.categories()
      |> Enum.map_join("\n", fn category ->
        " - #{category}: #{minutes_by_category |> Map.get(category, 0) |> format_time()}"
      end)

    """
    Month: #{month_report.name}
    #{categories_str}
       Total: #{format_time(total_minutes)}, Days: #{days_count}, Avg: #{format_time(avg_minutes_by_day)}
    """
  end
end
