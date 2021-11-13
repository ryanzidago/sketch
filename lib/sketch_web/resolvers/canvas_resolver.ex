defmodule SketchWeb.CanvasResolver do
  alias Sketch.Canvases
  alias Sketch.Canvases.Canvas

  def all(_parent, _args, _resolution) do
    {:ok, Canvas.all()}
  end

  def get(_parent, %{id: id}, _resolution) do
    {:ok, Canvas.get!(id)}
  end

  def create_canvas(_parents, %{width: width, height: height}, _resolution) do
    canvas = Canvases.new({width, height})
    {:ok, Canvas.insert!(canvas)}
  end

  def create_canvas(_parents, _args, _resolution) do
    canvas = Canvases.new()
    {:ok, Canvas.insert!(canvas)}
  end

  def draw_rectangle(_parent, %{id: id, x: x, y: y, width: w, height: h} = args, _resolution) do
    fill_character = Map.get(args, :fill_character)
    outline_character = Map.get(args, :outline_character)
    opts = [fill_character: fill_character, outline_character: outline_character]

    canvas = Canvas.get!(id)
    changes = Canvases.draw_rectangle(canvas, {x, y}, {w, h}, opts)
    canvas = Canvas.update!(canvas, changes)

    {:ok, canvas}
  end

  def flood_fill(_parent, %{id: id, x: x, y: y, fill_character: fill_character}, _resolution) do
    canvas = Canvas.get!(id)
    changes = Canvases.flood_fill(canvas, {x, y}, fill_character: fill_character)
    canvas = Canvas.update!(canvas, changes)

    {:ok, canvas}
  end
end
