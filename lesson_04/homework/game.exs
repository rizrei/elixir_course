defmodule Game do
  @type user_role() :: :admin | :moderator | :member
  @type user() :: {:user, String.t(), pos_integer(), user_role()}

  @spec join_game(user()) :: :ok | :error
  def join_game({:user, _, _, :admin}), do: :ok
  def join_game({:user, _, _, :moderator}), do: :ok
  def join_game({:user, _, age, _}) when age > 18, do: :ok
  def join_game(_), do: :error

  @type figure_color() :: :white | :black
  @type figure_type() :: :pawn | :rock | :bishop | :knight | :queen | :ki
  @type figure() :: {figure_type(), figure_color()}

  @spec move_allowed?(figure_color(), figure()) :: boolean()
  def move_allowed?(color, {:pawn, color}), do: true
  def move_allowed?(color, {:rock, color}), do: true
  def move_allowed?(_, _), do: false

  @spec single_win?(boolean(), boolean()) :: boolean()
  def single_win?(a_win, b_win), do: a_win !== b_win

  @spec double_win?(boolean(), boolean(), boolean()) :: :ab | :ac | :bc | false
  def double_win?(true, true, false), do: :ab
  def double_win?(true, false, true), do: :ac
  def double_win?(false, true, true), do: :bc
  def double_win?(_, _, _), do: false
end
