defmodule WorkReport.Report.Task do
  @moduledoc """
  Represents a task in the work report.
  """

  @categories ["COMM", "DEV", "DOC", "EDU", "OPS", "WS"]

  @type t :: %__MODULE__{
          category: String.t(),
          description: String.t(),
          position: integer() | nil,
          minutes: integer()
        }

  @enforce_keys [:category, :description, :minutes]
  defstruct [:category, :description, :position, :minutes]

  @spec new(%{category: String.t(), description: String.t(), minutes: non_neg_integer()}) ::
          {:ok, t()} | {:error, String.t()}
  def new(%{category: category}) when category not in @categories,
    do: {:error, "Invalid task category: #{category}"}

  def new(attributes), do: {:ok, struct(__MODULE__, attributes)}

  @spec categories() :: [String.t()]
  def categories(), do: @categories
end
