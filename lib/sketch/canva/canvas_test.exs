defmodule Sketch.Canvases.CanvasTest do
  use Sketch.DataCase

  alias Sketch.Canvases
  alias Sketch.Canvases.Canvas

  setup do
    canvas = Canvases.new({10, 5})

    {
      :ok,
      canvas: canvas
    }
  end

  describe "insert!/1" do
    test "inserts a new canva in the database", %{canvas: canvas} do
      canvas = Canvas.insert!(canvas)

      assert canvas.id
      assert canvas.board
      assert canvas.width == 10
      assert canvas.height == 5
      assert canvas.inserted_at
      assert canvas.updated_at
    end
  end

  describe "update!/1" do
    test "updates a canva in the database", %{canvas: canvas} do
      canvas =
        canvas
        |> Canvas.insert!()
        |> Canvas.update!(%{board: %{{0, 0} => "X"}})

      assert canvas.board == %{{0, 0} => "X"}
    end
  end
end
