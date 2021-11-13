defmodule Sketch.Canva do
  def new do
    for x <- 0..(24 - 1), y <- 0..(24 - 1), into: %{}, do: {{x, y}, " "}
  end
end
