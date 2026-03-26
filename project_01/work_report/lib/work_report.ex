defmodule WorkReport do
  @moduledoc """
  Analyze report file and gather work statistics
  """

  alias WorkReport.State

  import WorkReport.Protocols.Reportable, only: [report: 1]

  @name "Work Report"
  @version "1.0.0"

  @spec main([String.t()]) :: :ok
  def main(args) do
    case OptionParser.parse(args, options()) do
      {[help: true], [], []} -> help()
      {[version: true], [], []} -> version()
      {params, [file_path], []} -> do_report(file_path, params)
      _ -> help()
    end
  end

  defp do_report(file_path, params) do
    with %State{} = state <- State.new(file_path, params),
         :ok <- State.validate(state),
         {:ok, month, day} <- State.parse(state) do
      Enum.each([day, month], &(&1 |> report() |> IO.puts()))
    else
      {:error, reason} -> IO.puts(reason)
    end
  end

  defp help do
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

  defp version, do: IO.puts(@name <> " v" <> @version)

  defp options do
    [
      strict: [day: :integer, month: :integer, version: :boolean, help: :boolean],
      aliases: [d: :day, m: :month, v: :version, h: :help]
    ]
  end
end
