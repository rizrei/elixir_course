defmodule Chat.Rooms.Room do
  @moduledoc """
  Room struct and type definition.
  """

  alias Chat.Users.User

  @type name() :: String.t()
  @type type() :: :public | :private
  @type t :: %__MODULE__{
          name: name(),
          type: type(),
          members: [User.t()],
          limit: pos_integer()
        }
  @enforce_keys [:name]
  defstruct [
    :name,
    type: :public,
    members: [],
    limit: 100
  ]

  @spec public?(t()) :: boolean()
  def public?(%__MODULE__{type: type}), do: type == :public

  @spec reached_limit?(t()) :: boolean()
  def reached_limit?(%__MODULE__{limit: limit, members: members}) do
    length(members) == limit
  end

  @spec member?(t(), User.t()) :: boolean()
  def member?(%__MODULE__{members: members}, %User{} = user) do
    Enum.member?(members, user)
  end
end
