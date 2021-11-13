defmodule Sketch.CanvaTest do
  use ExUnit.Case

  alias Sketch.Canva

  describe "new/0" do
    test "creates a new empty 24 * 24 canva" do
      canva = Canva.new()

      for x <- 0..(24 - 1), y <- 0..(24 - 1) do
        assert Map.get(canva, {x, y}) == " "
      end
    end
  end
end
