defmodule SketchWeb.CanvasQueries do
  def on_canvas_created do
    """
    subscription {
      onCanvasCreated {
        id
        board
      }
    }
    """
  end

  def on_canvas_updated(id) do
    """
    subscription {
      onCanvasUpdated(id:"#{id}") {
        id
        board
      }
    }
    """
  end
end
