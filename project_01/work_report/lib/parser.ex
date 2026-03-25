defmodule WorkReport.Parser do
  alias WorkReport.Report.{Month, Day, Task}

  @month_regex ~r/# (?<month>[A-Za-z]+)/
  @day_regex ~r/## (?<day>\d+) (?<name>.+)/
  @task_regex ~r/
    ^\[?(?<category>\w+)\]?\s+
    (?<description>.+?)\s*-\s*
    (?=(?:\d+h|\d+m))
    ((?<hours>\d+)h)?\s*
    ((?<minutes>\d+)m)?$/x

  def parse(str) do
    cond do
      Regex.match?(@month_regex, str) ->
        %{"month" => month} = Regex.named_captures(@month_regex, str)
        Month.new(month)

      Regex.match?(@day_regex, str) ->
        %{"day" => day, "name" => name} = Regex.named_captures(@day_regex, str)
        %Day{name: name, number: String.to_integer(day)}

      Regex.match?(@task_regex, str) ->
        %{
          "category" => category,
          "description" => description,
          "hours" => hours,
          "minutes" => minutes
        } = Regex.named_captures(@task_regex, str)

        Task.new(category, description, hours, minutes)

      true ->
        :unknown_line_format
    end
  end
end
