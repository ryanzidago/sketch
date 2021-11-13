defmodule Sketch.CanvaTest do
  use ExUnit.Case

  alias Sketch.Canva

  setup _ do
    {
      :ok,
      opts: [fill_character: "X"]
    }
  end

  describe "new/0" do
    test "creates a new empty 24 * 24 canva" do
      canva = Canva.new()

      Enum.each(all_cells(), fn {x, y} ->
        assert Map.get(canva, {x, y}) == " "
      end)
    end
  end

  test "test fixutre 1" do
    canva =
      Canva.new()
      |> Canva.draw_rectangle({3, 2}, {5, 3}, outline_character: "@", fill_character: "X")
      |> Canva.draw_rectangle({10, 3}, {14, 6}, outline_character: "X", fill_character: "O")

    expected = """
    @@@@@
    @XXX@  XXXXXXXXXXXXXX
    @@@@@  XOOOOOOOOOOOOX
           XOOOOOOOOOOOOX
           XOOOOOOOOOOOOX
           XOOOOOOOOOOOOX
           XXXXXXXXXXXXXX
    """

    assert String.split(Canva.pretty(canva)) == String.split(expected)
  end

  test "test fixture 2" do
    canva =
      Canva.new()
      |> Canva.draw_rectangle({15, 0}, {7, 6}, fill_character: ".")
      |> Canva.draw_rectangle({0, 3}, {8, 4}, outline_character: "O")
      |> Canva.draw_rectangle({5, 5}, {5, 3}, outline_character: "X", fill_character: "X")

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

    assert String.split(Canva.pretty(canva)) == String.split(expected)
  end

  defp all_cells do
    for x <- 0..(24 - 1), y <- 0..(24 - 1), into: MapSet.new() do
      {x, y}
    end
  end
end
