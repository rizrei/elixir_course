defmodule Chat.Users do
  @moduledoc """
  Users module with the main logic of getting users.
  """

  alias Chat.Users.User

  @users [
    %User{name: "User 1"},
    %User{name: "User 2"},
    %User{name: "User 3"}
  ]

  @spec get_user(User.name()) :: {:ok, User.t()} | {:error, :not_found}
  def get_user(name) do
    res = Enum.find(@users, fn user -> user.name == name end)

    if res, do: {:ok, res}, else: {:error, :not_found}
  end
end
