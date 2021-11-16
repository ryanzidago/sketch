defmodule SketchWeb.Graphql.CanvasResolverTest do
  use Sketch.DataCase

  alias Sketch.{Canvas, CanvasRepo}
  alias SketchWeb.Graphql.CanvasResolver

  setup do
    canvases = for _ <- 1..3, do: CanvasRepo.insert!(Canvas.new())

    {
      :ok,
      canvases: canvases
    }
  end

  describe "all/3" do
    test "returns all Canvases", %{canvases: canvases} do
      {:ok, canvases_from_resolver} = CanvasResolver.all([], [], [])

      for canvas <- canvases do
        assert canvas in canvases_from_resolver
      end
    end
  end

  describe "get/3" do
    test "gets a canvas for a specific id", %{canvases: [canvas | _]} do
      {:ok, canvas_from_resolver} = CanvasResolver.get(%{}, %{id: canvas.id}, %{})
      assert canvas_from_resolver == canvas
    end

    test "returns `{:error, error} if no canvas for the id exist" do
      assert {:error, _} = CanvasResolver.get(%{}, %{id: Ecto.UUID.generate()}, %{})
    end

    test "returns an `{:error, error}` if the id isn not a UUID" do
      assert {:error, _} = CanvasResolver.get(%{}, %{id: "1"}, %{})
    end
  end

  describe "create_canvas/3" do
    test "creates a canvas for the given width and height" do
      assert {:ok, canvas} = CanvasResolver.create_canvas(%{}, %{width: 24, height: 24}, %{})
      assert %Canvas{width: 24, height: 24} = canvas
    end

    test "creates a canvas with default dimensions if no width and height are given" do
      assert {:ok, canvas} = CanvasResolver.create_canvas(%{}, %{}, %{})
      assert %Canvas{width: 24, height: 24} = canvas
    end
  end

  describe "draw_rectangle/3" do
    test "draws a rectangle on the given canvas", %{canvases: [canvas | _]} do
      params = %{id: canvas.id, x: 0, y: 0, width: 5, height: 5, fill_character: "@"}
      assert {:ok, updated_canvas} = CanvasResolver.draw_rectangle(%{}, params, %{})

      assert updated_canvas.board ==
               canvas
               |> Canvas.draw_rectangle({0, 0}, {5, 5}, fill_character: "@")
               |> Map.get(:board)
    end

    test "returns an `{:error, error}` in case the Canvas does not exists" do
      params = %{id: Ecto.UUID.generate(), x: 0, y: 0, width: 5, height: 5, fill_character: "@"}
      assert {:error, _} = CanvasResolver.draw_rectangle(%{}, params, %{})
    end

    test "returns an `{:error, error}` in case a required argument is missing", %{
      canvases: [canvas | _]
    } do
      params = %{id: canvas.id, x: 0, y: 0, width: 5, height: 5}
      assert {:error, _} = CanvasResolver.draw_rectangle(%{}, params, %{})
    end
  end

  describe "flood_fill/3" do
    test "flood fills a canvas", %{canvases: [canvas | _]} do
      params = %{id: canvas.id, x: 0, y: 0, fill_character: "@"}
      assert {:ok, updated_canvas} = CanvasResolver.flood_fill(%{}, params, %{})

      assert updated_canvas.board ==
               canvas
               |> Canvas.flood_fill({0, 0}, fill_character: "@")
               |> Map.get(:board)
    end

    test "returns an `{:error, error}` in case the Canvas does not exist" do
      params = %{id: Ecto.UUID.generate(), x: 0, y: 0, fill_character: "@"}
      assert {:error, _} = CanvasResolver.flood_fill(%{}, params, %{})
    end
  end

  describe "board/3" do
    test "dumps the board and encode it as JSON", %{canvases: [canvas | _]} do
      assert {:ok, board_json} = CanvasResolver.board(canvas, %{}, %{})
      assert {:ok, board} = board_json |> Jason.decode!() |> Canvas.EctoBoard.load()
      assert board == canvas.board
    end
  end
end
