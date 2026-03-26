defprotocol WorkReport.Protocols.Reportable do
  @moduledoc """
  Protocol for report entities: Month and Day.

  Defines a function `report/1` that takes an entity and returns a formatted string representation of it.
  This protocol allows for different formatting logic for Month and Day entities while keeping the main reporting logic in the WorkReport module clean and focused on data processing.
  Implementations of this protocol should be provided for both Month and Day structs to enable consistent reporting across different types of entities.
  The `report/1` function should return a string that can be printed to the console, containing relevant information about the entity, such as total time spent, tasks, and other statistics.
  """

  def report(entity)
end
