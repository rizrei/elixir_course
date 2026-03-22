defmodule Chat.ChatRoom do
  @moduledoc """
  ChatRoom module with the main logic of joining rooms.
  """

  alias Chat.{Rooms, Users}
  alias Rooms.Room
  alias Users.User

  @spec join_room(User.name(), Room.name()) :: {:ok, Room.t()} | {:error, atom()}
  def join_room(user_name, room_name) do
    with {:ok, user} <- get_user(user_name),
         {:ok, room} <- get_room(room_name) do
      Rooms.join(room, user)
    end
  end

  @spec get_user(User.name()) :: {:ok, User.t()} | {:error, :user_not_found}
  defp get_user(name) do
    case Users.get_user(name) do
      {:ok, user} -> {:ok, user}
      {:error, :not_found} -> {:error, :user_not_found}
    end
  end

  @spec get_room(Room.name()) :: {:ok, Room.t()} | {:error, :room_not_found}
  defp get_room(name) do
    case Rooms.get_room(name) do
      {:ok, room} -> {:ok, room}
      {:error, :not_found} -> {:error, :room_not_found}
    end
  end
end
