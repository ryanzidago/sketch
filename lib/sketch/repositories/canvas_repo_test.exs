defmodule Sketch.CanvasRepoTest do
  use Sketch.DataCase

  alias Sketch.{Canvas, CanvasRepo}

  setup do
    canvases = _ = for _ <- 1..3, do: CanvasRepo.insert!(Canvas.new())

    {
      :ok,
      canvases: canvases
    }
  end

  describe "all/0" do
    test "returns all canvases saved in the database" do
      assert [%Canvas{}, %Canvas{}, %Canvas{}] = CanvasRepo.all()
    end
  end

  describe "all_ids/0" do
    test "returns a list of all canvases' id" do
      for canvas_id <- CanvasRepo.all_ids() do
        assert CanvasRepo.get(canvas_id)
      end
    end
  end

  describe "get/1" do
    test "returns a canvas for the given id" do
      canvas = CanvasRepo.insert!(Canvas.new())
      assert ^canvas = CanvasRepo.get(canvas.id)
    end

    test "returns an `{:error, error}` if the `id` is not a UUID" do
      assert {:error, "ID must be a UUID"} = CanvasRepo.get(1)
    end

    test "returns `nil` if the canvas does not exist" do
      refute CanvasRepo.get(Ecto.UUID.generate())
    end
  end

  describe "insert!/1" do
    test "inserts a canvas in the database" do
      assert %Canvas{} = CanvasRepo.insert!(Canvas.new())
    end
  end

  describe "insert/1" do
    test "inserts a canvas in the database" do
      assert {:ok, %Canvas{}} = CanvasRepo.insert(Canvas.new())
    end
  end

  describe "update/1" do
    test "updates the given canvas in the database" do
      assert canvas = CanvasRepo.insert!(Canvas.new())
      canvas = Canvas.flood_fill(canvas, {0, 0}, fill_character: "X")
      assert {:ok, ^canvas} = CanvasRepo.update(canvas)
    end

    test "prevents updating the board's size" do
      assert canvas = CanvasRepo.insert!(Canvas.new())
      invalid_canvas = %Canvas{canvas | width: 0, height: 0}
      assert {:ok, canvas} = CanvasRepo.update(canvas)
      assert canvas != invalid_canvas
    end
  end
end
