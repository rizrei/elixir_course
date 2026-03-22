defmodule Chat.ChatRoomTest do
  @moduledoc false

  use ExUnit.Case

  alias Chat.ChatRoom
  alias Chat.Users.User

  test "User 1 test" do
    assert {:ok, %{members: [%User{name: "User 1"} | []]}} =
             ChatRoom.join_room("User 1", "Room 1")

    assert ChatRoom.join_room("User 1", "Room 2") == {:error, :not_allowed}
    assert ChatRoom.join_room("User 1", "Room 3") == {:error, :room_reached_limit}
    assert ChatRoom.join_room("User 1", "Room 4") == {:error, :room_not_found}
  end

  test "User 2 test" do
    assert {:ok, %{members: [%User{name: "User 2"} | []]}} =
             ChatRoom.join_room("User 2", "Room 1")

    assert ChatRoom.join_room("User 2", "Room 2") == {:error, :not_allowed}
    assert ChatRoom.join_room("User 2", "Room 3") == {:error, :room_reached_limit}
    assert ChatRoom.join_room("User 2", "Room 4") == {:error, :room_not_found}
  end

  test "User 3 test" do
    assert {:ok, %{members: [%User{name: "User 3"} | []]}} =
             ChatRoom.join_room("User 3", "Room 1")

    assert ChatRoom.join_room("User 3", "Room 2") == {:error, :not_allowed}
    assert ChatRoom.join_room("User 3", "Room 3") == {:error, :room_reached_limit}
    assert ChatRoom.join_room("User 3", "Room 4") == {:error, :room_not_found}
  end

  test "User 4 test" do
    assert ChatRoom.join_room("User 4", "Room 1") == {:error, :user_not_found}
    assert ChatRoom.join_room("User 4", "Room 2") == {:error, :user_not_found}
    assert ChatRoom.join_room("User 4", "Room 3") == {:error, :user_not_found}
    assert ChatRoom.join_room("User 4", "Room 4") == {:error, :user_not_found}
  end
end
