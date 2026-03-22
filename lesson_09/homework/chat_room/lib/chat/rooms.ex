defmodule Chat.Rooms do
  @moduledoc """
  Chat.Rooms module with the main logic of joining rooms and getting rooms.
  """

  alias Chat.Rooms.Room
  alias Chat.Users.User

  @rooms [
    %Room{name: "Room 1", type: :public},
    %Room{
      name: "Room 2",
      type: :private,
      members: [%User{name: "User 1"}, %User{name: "User 2"}]
    },
    %Room{name: "Room 3", type: :public, limit: 0}
  ]

  @spec get_room(Room.name()) :: {:ok, Room.t()} | {:error, :not_found}
  def get_room(name) do
    res = Enum.find(@rooms, fn %Room{name: room_name} -> room_name == name end)

    if res, do: {:ok, res}, else: {:error, :not_found}
  end

  @spec join(Room.t(), User.t()) :: {:ok, Room.t()} | {:error, :not_allowed | :room_reached_limit}
  def join(%Room{type: :private}, _), do: {:error, :not_allowed}

  def join(%Room{members: members, limit: limit}, _) when length(members) == limit,
    do: {:error, :room_reached_limit}

  def join(%Room{members: members} = room, %User{} = user) do
    if Room.member?(room, user), do: {:ok, room}, else: {:ok, %{room | members: [user | members]}}
  end
end
