defmodule SketchWeb.SchemaTest do
  use SketchWeb.ConnCase

  alias Sketch.{Canvas, CanvasRepo}

  setup do
    _canvas = CanvasRepo.insert!(Canvas.new())
    canvas = CanvasRepo.insert!(Canvas.new())

    {:ok, canvas: canvas}
  end

  describe "canvas" do
    test "returns a canvas for a given id", %{conn: conn, canvas: canvas} do
      params = %{"query" => canvas_query(), "variables" => %{id: canvas.id}}
      conn = post(conn, "/api", params)

      response = json_response(conn, 200)
      canvas = response["data"]["canvas"]

      assert canvas["board"]
      assert canvas["height"] == 24
      assert canvas["width"] == 24
    end
  end

  describe "canvases" do
    test "returns a list of all canvases", %{conn: conn} do
      params = %{"query" => canvases_query()}
      conn = post(conn, "/api", params)

      response = json_response(conn, 200)
      canvases = response["data"]["canvases"]

      assert length(canvases) == 2

      for canvas <- canvases do
        assert canvas["board"]
        assert canvas["height"] == 24
        assert canvas["width"] == 24
      end
    end
  end

  describe "createCanvas" do
    test "creates a canvas with default width and height, if both of those parameters aren't given",
         %{conn: conn} do
      params = %{"query" => create_canvas_with_default_size_query()}
      conn = post(conn, "/api", params)

      response = json_response(conn, 200)
      canvas = response["data"]["createCanvas"]

      assert canvas = CanvasRepo.get(canvas["id"])
      assert canvas.board
      assert canvas.width == 24
      assert canvas.height == 24
    end

    test "creates a canvas with a given width and height",
         %{conn: conn} do
      params = %{"query" => create_canvas_query(), "variables" => %{width: 21, height: 8}}
      conn = post(conn, "/api", params)

      response = json_response(conn, 200)
      canvas = response["data"]["createCanvas"]

      assert canvas = CanvasRepo.get(canvas["id"])
      assert canvas.board
      assert canvas.width == 21
      assert canvas.height == 8
    end
  end

  describe "drawRectangle" do
    test "draws a rectangle", %{conn: conn, canvas: canvas} do
      variables = %{
        id: canvas.id,
        x: 10,
        y: 10,
        width: 6,
        height: 4,
        fill_character: "X",
        outline_character: "@"
      }

      params = %{"query" => draw_rectangle_query(), "variables" => variables}
      conn = post(conn, "/api", params)

      response = json_response(conn, 200)
      canvas = response["data"]["drawRectangle"]

      assert canvas = CanvasRepo.get(canvas["id"])

      expected = """
      @@@@@@
      @XXXX@
      @XXXX@
      @@@@@@
      """

      assert String.split(expected) == String.split(Canvas.pretty(canvas))
    end
  end

  describe "floodFill" do
    test "flood fills a given canvas", %{conn: conn, canvas: canvas} do
      variables = %{
        id: canvas.id,
        x: 0,
        y: 0,
        fill_character: "-"
      }

      params = %{"query" => flood_fill_query(), "variables" => variables}
      conn = post(conn, "/api", params)

      response = json_response(conn, 200)

      canvas = response["data"]["floodFill"]

      assert canvas = CanvasRepo.get(canvas["id"])

      assert Canvas.pretty(canvas) == """
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             ------------------------
             """
    end
  end

  defp canvas_query do
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

  defp canvases_query do
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

  defp create_canvas_with_default_size_query do
    """
    mutation CreateCanvas {
      createCanvas {
        id
      }
    }
    """
  end

  defp create_canvas_query do
    """
    mutation CreateCanvas($height: Int!, $width: Int!) {
      createCanvas(height: $height, width: $width) {
        id
      }
    }
    """
  end

  defp draw_rectangle_query do
    """
    mutation DrawRectangle($id: ID!, $x: Int!, $y: Int!, $width: Int!, $height: Int!, $fill_character: String!, $outline_character: String!) {
      drawRectangle(id: $id, x: $x, y: $y, width: $width, height: $height, fillCharacter: $fill_character, outlineCharacter: $outline_character) {
        id
      }
    }
    """
  end

  defp flood_fill_query do
    """
    mutation FloodFill($id: ID!, $x: Int!, $y: Int!, $fill_character: String) {
      floodFill(id: $id, x: $x, y: $y, fillCharacter: $fill_character) {
        id
      }
    }
    """
  end
end
