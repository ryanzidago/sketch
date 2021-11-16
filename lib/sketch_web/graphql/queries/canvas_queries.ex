defmodule SketchWeb.Graphql.CanvasQueries do
  def canvas_query do
    """
    query Canvas($id: ID!) {
      canvas(id: $id) {
        id
        board
        width
        height
      }
    }
    """
  end

  def canvases_query do
    """
    query Canvases {
      canvases {
        id
        board
        width
        height
      }
    }
    """
  end

  def create_canvas_with_default_size_query do
    """
    mutation CreateCanvas {
      createCanvas {
        id
      }
    }
    """
  end

  def create_canvas_query do
    """
    mutation CreateCanvas($height: Int!, $width: Int!) {
      createCanvas(height: $height, width: $width) {
        id
      }
    }
    """
  end

  def draw_rectangle_query do
    """
    mutation DrawRectangle($id: ID!, $x: Int!, $y: Int!, $width: Int!, $height: Int!, $fill_character: String!, $outline_character: String!) {
      drawRectangle(id: $id, x: $x, y: $y, width: $width, height: $height, fillCharacter: $fill_character, outlineCharacter: $outline_character) {
        id
      }
    }
    """
  end

  def flood_fill_query do
    """
    mutation FloodFill($id: ID!, $x: Int!, $y: Int!, $fill_character: String) {
      floodFill(id: $id, x: $x, y: $y, fillCharacter: $fill_character) {
        id
      }
    }
    """
  end

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
