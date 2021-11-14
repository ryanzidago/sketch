defmodule SketchWeb.CanvasView do
  use SketchWeb, :view

  def as_rows(board, {_w, _h}) do
    for x <- 0..(24 - 1) do
      for y <- 0..(24 - 1) do
        board[{x, y}]
      end
    end
  end
end
