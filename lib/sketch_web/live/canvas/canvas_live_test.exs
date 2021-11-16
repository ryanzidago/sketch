defmodule SketchWeb.CanvasLiveTest do
  use SketchWeb.ConnCase

  alias Sketch.{Canvas, CanvasRepo}
  alias SketchWeb.Router
  alias SketchWeb.Endpoint

  import SketchWeb.Graphql.CanvasQueries
  import Phoenix.LiveViewTest

  setup do
    canvas = CanvasRepo.insert!(Canvas.new({24, 24}))
    canvas_path = Router.Helpers.canvas_path(Endpoint, :show, canvas.id)
    canvases_path = Router.Helpers.canvas_path(Endpoint, :index)

    {
      :ok,
      canvas: canvas, canvas_path: canvas_path, canvases_path: canvases_path
    }
  end

  describe "mount/3" do
    test "subscribes to `on_canvas_created`", %{
      conn: conn,
      canvases_path: canvases_path
    } do
      {:ok, view, _html} = live(conn, canvases_path)

      params = %{"query" => create_canvas_with_default_size_query()}
      conn = post(conn, "/api", params)
      response = json_response(conn, 200)

      html = render(view)

      assert html =~ response["data"]["createCanvas"]["id"]
    end

    test "subscribes to `on_canvas_updated` if a canvas_id is given as a params", %{
      conn: conn,
      canvas: canvas,
      canvas_path: canvas_path
    } do
      {:ok, view, _html} = live(conn, canvas_path)

      variables = %{
        id: canvas.id,
        x: 0,
        y: 0,
        fill_character: "@"
      }

      params = %{"query" => flood_fill_query(), "variables" => variables}
      conn = post(conn, "/api", params)

      response = json_response(conn, 200)
      assert response["data"]["floodFill"]["id"]

      html = render(view)

      html = String.replace(html, ~r/[^@]/, "")

      assert html == for(_ <- 1..(canvas.width * canvas.height), into: "", do: "@")
    end
  end
end
