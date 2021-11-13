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

  describe "draw_recantgle/4" do
    test "draws a rectangle on the canva, at the position {x, y}, whose size is w * h", %{
      opts: opts
    } do
      x = 0
      y = 0
      w = 2
      h = 2

      canva = Canva.draw_rectangle(Canva.new(), {x, y}, {w, h}, opts)
      drawn_cells = all_cells_for_xy_and_wh({x, y}, {w, h})

      Enum.each(all_cells(), fn {x, y} ->
        if {x, y} in drawn_cells do
          assert canva[{x, y}] == opts[:fill_character]
        else
          assert canva[{x, y}] == " "
        end
      end)
    end

    test "draws a single cell", %{opts: opts} do
      x = 0
      y = 0
      w = 1
      h = 1

      canva = Canva.draw_rectangle(Canva.new(), {x, y}, {w, h}, opts)
      drawn_cells = all_cells_for_xy_and_wh({x, y}, {w, h})

      Enum.each(all_cells(), fn {x, y} ->
        if {x, y} in drawn_cells do
          assert canva[{x, y}] == opts[:fill_character]
        else
          assert canva[{x, y}] == " "
        end
      end)
    end

    test "uses the `:outline_character` if it is the only character given in the opts " do
      x = 0
      y = 0
      w = 2
      h = 2
      opts = [outline_character: "@"]

      canva = Canva.draw_rectangle(Canva.new(), {x, y}, {w, h}, opts)
      drawn_cells = all_cells_for_xy_and_wh({x, y}, {w, h})

      Enum.each(all_cells(), fn {x, y} ->
        if {x, y} in drawn_cells do
          assert canva[{x, y}] == opts[:outline_character]
        else
          assert canva[{x, y}] == " "
        end
      end)
    end
  end

  # - rectange at {3, 2} with w: 5, h: 3, outline_character: "@", fill_character: "X"
  # - rectangle at {10, 3} with w: 14, h: 6, outline_character: "X, fill_character: "O
  test "test fixutre 1" do
    canva =
      Canva.new()
      |> Canva.draw_rectangle({3, 2}, {5, 3}, outline_character: "@", fill_character: "X")
      |> Canva.draw_rectangle({10, 3}, {14, 6}, outline_character: "X", fill_character: "O")

    expected = """
    @@@@@
    @XXX@  XXXXXXXXXXXXXX
    @XXX@  XOOOOOOOOOOOOX
    @@@@@  XOOOOOOOOOOOOX
           XOOOOOOOOOOOOX
           XOOOOOOOOOOOOX
           XOOOOOOOOOOOOX
           XXXXXXXXXXXXXX
    """

    assert String.split(Canva.pretty(canva)) == String.split(expected)
  end

  defp all_cells do
    for x <- 0..(24 - 1), y <- 0..(24 - 1), into: MapSet.new() do
      {x, y}
    end
  end

  defp all_cells_for_xy_and_wh({x, y}, {w, h}) do
    for x <- x..(w - 1), y <- y..(h - 1), into: MapSet.new(), do: {x, y}
  end
end
