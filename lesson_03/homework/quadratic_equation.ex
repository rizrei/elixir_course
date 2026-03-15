defmodule QuadraticEquation do
  @moduledoc """
  https://en.wikipedia.org/wiki/Quadratic_equation
  """

  @doc """
  function accepts 3 integer arguments and returns:
  {:roots, root_1, root_2} or {:root, root_1} or :no_root

  ## Examples
      iex> QuadraticEquation.solve(1, -2, -3)
      {:roots, 3.0, -1.0}
      iex> QuadraticEquation.solve(3, 5, 10)
      :no_roots
  """
  def solve(a, b, c) do
    discriminant(a, b, c) |> roots(a, b)
  end

  defp discriminant(a, b, c), do: :math.pow(b, 2) - 4 * a * c

  defp roots(0.0, a, b), do: {:root, -b / (2 * a)}

  defp roots(d, a, b) when d > 0 do
    {:roots, (-b + :math.sqrt(d)) / (2 * a), (-b - :math.sqrt(d)) / (2 * a)}
  end

  defp roots(_, _, _), do: :no_roots
end
