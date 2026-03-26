defmodule WorkReport.Formatter do
  @moduledoc """
  Formatter for work report entities: Month and Day.

  Provides functions to format time and generate report strings for Month and Day entities.
  The main function is `format_time/1` which converts minutes into a human-readable format.
  It handles various cases such as zero minutes, minutes less than an hour, and minutes greater than or equal to an hour.
  For example:
    - `format_time(0)` returns "0"
    - `format_time(45)` returns "45m"
    - `format_time(120)` returns "2h"
    - `format_time(135)` returns "2h 15m"
  """

  @spec format_time(number()) :: String.t()
  def format_time(0), do: "0"

  def format_time(minutes) when is_float(minutes), do: minutes |> trunc() |> format_time()
  def format_time(minutes) when 0 < minutes and minutes < 60, do: "#{minutes}m"

  def format_time(minutes) when minutes >= 60 do
    %{hours: div(minutes, 60), minutes: rem(minutes, 60)}
    |> then(fn
      %{hours: hours, minutes: 0} -> "#{hours}h"
      %{hours: hours, minutes: remaining} -> "#{hours}h #{remaining}m"
    end)
  end
end
