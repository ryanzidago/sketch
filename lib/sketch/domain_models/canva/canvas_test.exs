defmodule Sketch.CanvasTest do
  use ExUnit.Case

  alias Sketch.Canvas

  setup _ do
    canvas = Canvas.new()

    {
      :ok,
      canvas: canvas, opts: [fill_character: "X"]
    }
  end

  describe "new/{0, 1}" do
    test "creates a new empty 24 * 24 canvas" do
      canvas = Canvas.new()

      Enum.each(all_cells(), fn {x, y} ->
        assert Map.get(canvas.board, {x, y}) == " "
      end)
    end

    test "creates a new empty w * h canvas" do
      canvas = Canvas.new({21, 8})

      Enum.each(all_cells({21, 8}), fn {x, y} ->
        assert Map.get(canvas.board, {x, y}) == " "
      end)
    end

    test "returns an `{:error, error}` Tuple if the dimensions exceed 24 * 24" do
      assert {:error, "Dimension exceeds maximum board size (24 * 24"} = Canvas.new({100, 100})
    end

    test "returns an `{:error, error}` Tuple when the dimensions are smaller than 2 * 2" do
      assert {:error, "Dimensions must be at least 2 * 2"} = Canvas.new({1, 1})
    end
  end

  describe "draw_rectangle/4" do
    test "returns an `{:error, error}` Tuple if the coordinates are outside of the board's surface",
         %{canvas: canvas} do
      assert result = Canvas.draw_rectangle(canvas, {100, 100}, {1, 1}, fill_character: "X")
      assert {:error, "Coordinates outside of the board's surface"} = result
    end

    test "returns an `{:error, error}` Tuple if the coordinates are negative", %{canvas: canvas} do
      assert result = Canvas.draw_rectangle(canvas, {-1, -1}, {1, 1}, fill_character: "X")
      assert {:error, "Coordinates are negative"} = result
    end

    test "returns an `{:error, error}` Tuple if the requested rectangle would be outside of the board",
         %{canvas: canvas} do
      assert result = Canvas.draw_rectangle(canvas, {20, 20}, {10, 10}, fill_character: "X")
      assert {:error, "Drawing outside of the board is not allowed"} = result
    end

    test "returns an `{:error, error}` Tuple if neither fill_character nor outline_character were given",
         %{canvas: canvas} do
      assert result = Canvas.draw_rectangle(canvas, {10, 10}, {1, 1}, [])
      assert {:error, "No fill_character or outline_character provided"} = result
    end
  end

  test "test fixutre 1" do
    canvas =
      Canvas.new()
      |> Canvas.draw_rectangle({3, 2}, {5, 3}, outline_character: "@", fill_character: "X")
      |> Canvas.draw_rectangle({10, 3}, {14, 6}, outline_character: "X", fill_character: "O")

    expected = """
    @@@@@
    @XXX@  XXXXXXXXXXXXXX
    @@@@@  XOOOOOOOOOOOOX
           XOOOOOOOOOOOOX
           XOOOOOOOOOOOOX
           XOOOOOOOOOOOOX
           XXXXXXXXXXXXXX
    """

    assert String.split(Canvas.pretty(canvas)) == String.split(expected)
  end

  test "test fixture 2" do
    canvas =
      Canvas.new()
      |> Canvas.draw_rectangle({15, 0}, {7, 6}, fill_character: ".")
      |> Canvas.draw_rectangle({0, 3}, {8, 4}, outline_character: "O")
      |> Canvas.draw_rectangle({5, 5}, {5, 3}, outline_character: "X", fill_character: "X")

    expected = """
                  .......
                  .......
                  .......
    OOOOOOOO      .......
    O      O      .......
    O    XXXXX    .......
    OOOOOXXXXX
         XXXXX
    """

    assert String.split(Canvas.pretty(canvas)) == String.split(expected)
  end

  test "test fixture 3" do
    canvas =
      Canvas.new({21, 8})
      |> Canvas.draw_rectangle({14, 0}, {7, 6}, fill_character: ".")
      |> Canvas.draw_rectangle({0, 3}, {8, 4}, outline_character: "O")
      |> Canvas.draw_rectangle({5, 5}, {5, 3}, outline_character: "X", fill_character: "X")
      |> Canvas.flood_fill({0, 0}, fill_character: "-")

    expected = """
    --------------.......
    --------------.......
    --------------.......
    OOOOOOOO------.......
    O      O------.......
    O    XXXXX----.......
    OOOOOXXXXX-----------
         XXXXX-----------
    """

    assert String.split(Canvas.pretty(canvas)) == String.split(expected)
  end

  defp all_cells({w, h} \\ {24, 24}) do
    for x <- 0..(h - 1), y <- 0..(w - 1), into: MapSet.new() do
      {x, y}
    end
  end
end
