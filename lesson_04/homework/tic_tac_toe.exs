defmodule TicTacToe do
  @type cell() :: :x | :o | :f
  @type row() :: {cell(), cell(), cell()}
  @type game_state() :: {row(), row(), row()}
  @type game_result :: {:win, :x} | {:win, :o} | :no_win

  @spec valid_game?(game_state()) :: boolean()
  def valid_game?({r1, r2, r3}), do: valid_row?(r1) and valid_row?(r2) and valid_row?(r3)
  def valid_game?(_), do: false

  defp valid_row?({cell1, cell2, cell3}),
    do: valid_cell?(cell1) and valid_cell?(cell2) and valid_cell?(cell3)

  defp valid_row?(_), do: false

  defp valid_cell?(cell) when cell in [:x, :o, :f], do: true
  defp valid_cell?(_), do: false

  @spec check_who_win(game_state()) :: game_result()
  def check_who_win({{cell, cell, cell}, _, _}) when cell in [:x, :o], do: {:win, cell}
  def check_who_win({_, {cell, cell, cell}, _}) when cell in [:x, :o], do: {:win, cell}
  def check_who_win({_, _, {cell, cell, cell}}) when cell in [:x, :o], do: {:win, cell}

  def check_who_win({
        {cell, _, _},
        {_, cell, _},
        {_, _, cell}
      })
      when cell in [:x, :o], do: {:win, cell}

  def check_who_win({
        {_, _, cell},
        {_, cell, _},
        {cell, _, _}
      })
      when cell in [:x, :o], do: {:win, cell}

  def check_who_win({
        {cell, _, _},
        {cell, _, _},
        {cell, _, _}
      })
      when cell in [:x, :o], do: {:win, cell}

  def check_who_win({
        {_, cell, _},
        {_, cell, _},
        {_, cell, _}
      })
      when cell in [:x, :o], do: {:win, cell}

  def check_who_win({
        {_, _, cell},
        {_, _, cell},
        {_, _, cell}
      })
      when cell in [:x, :o], do: {:win, cell}

  def check_who_win(_), do: :no_win
end
