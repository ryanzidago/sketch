defmodule Sketch.CanvasTest do
  use ExUnit.Case

  alias Sketch.Canvas

  setup _ do
    {
      :ok,
      opts: [fill_character: "X"]
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