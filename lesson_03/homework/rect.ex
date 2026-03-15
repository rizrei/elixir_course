defmodule Rect do
  @type point() :: {:point, integer(), integer()}
  @type rect() :: {:rect, point(), point()}

  @spec intersect(rect(), rect()) :: boolean()
  def intersect(
        {:rect, {:point, left1, top1}, {:point, right1, bottom1}} = rect1,
        {:rect, {:point, left2, top2}, {:point, right2, bottom2}} = rect2
      ) do
    unless valid_rect(rect1), do: raise("invalid rect 1")
    unless valid_rect(rect2), do: raise("invalid rect 2")

    no_x_overlap = right1 < left2 or right2 < left1
    no_y_overlap = bottom1 > top2 or bottom2 > top1
    not (no_x_overlap or no_y_overlap)
  end

  @spec valid_rect(rect()) :: boolean()
  def valid_rect({:rect, {:point, x1, y1}, {:point, x2, y2}}) when x1 < x2 and y1 > y2, do: true
  def valid_rect(_), do: false
end
