defmodule Chat.Users.User do
  @moduledoc """
  User struct and type definition.
  """

  @type name() :: String.t()

  @type t :: %__MODULE__{name: name()}
  @enforce_keys [:name]
  defstruct [:name]
end
