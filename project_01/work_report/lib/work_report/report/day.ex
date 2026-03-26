defmodule WorkReport.Report.Day do
  @moduledoc """
  Represents a day report in the work report.
  """

  alias WorkReport.Report.Task

  @type t :: %__MODULE__{
          number: non_neg_integer(),
          name: String.t(),
          next_task_position: pos_integer(),
          tasks: [Task.t()]
        }

  defstruct [:number, :name, next_task_position: 1, tasks: []]

  @spec add_task(t(), Task.t()) :: t()
  def add_task(day_report, task) do
    %{
      day_report
      | tasks: [%{task | position: day_report.next_task_position} | day_report.tasks],
        next_task_position: day_report.next_task_position + 1
    }
  end

  @spec total_minutes(t()) :: non_neg_integer()
  def total_minutes(%__MODULE__{tasks: tasks}), do: Enum.sum_by(tasks, & &1.minutes)

  @spec minutes_by_category(t()) :: %{String.t() => pos_integer()}
  def minutes_by_category(%__MODULE__{tasks: tasks}) do
    Enum.reduce(tasks, %{}, fn task, acc ->
      Map.update(acc, task.category, task.minutes, fn minutes -> minutes + task.minutes end)
    end)
  end

  defimpl WorkReport.Protocols.Reportable do
    @moduledoc """
    Implementation of the Reportable protocol for the Day struct.
    """

    alias WorkReport.Report.Day
    import WorkReport.Formatter, only: [format_time: 1]

    @spec report(Day.t()) :: String.t()
    def report(%Day{number: number, name: name, tasks: tasks} = day) do
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
  end
end
