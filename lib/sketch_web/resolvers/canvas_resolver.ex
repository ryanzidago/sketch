defmodule SketchWeb.CanvasResolver do
  alias Sketch.{Canvas, CanvasRepo}
  alias Canvas.EctoBoard

  def all(_parent, _args, _resolution) do
    {:ok, CanvasRepo.all()}
  end

  def get(_parent, %{id: id}, _resolution) do
    {:ok, CanvasRepo.get!(id)}
  end

  def create_canvas(_parents, %{width: width, height: height}, _resolution) do
    canvas = Canvas.new({width, height})
    {:ok, CanvasRepo.insert!(canvas)}
  end

  def create_canvas(_parents, _args, _resolution) do
    canvas = Canvas.new()
    {:ok, CanvasRepo.insert!(canvas)}
  end

  def draw_rectangle(_parent, %{id: id, x: x, y: y, width: w, height: h} = args, _resolution) do
    fill_character = Map.get(args, :fill_character)
    outline_character = Map.get(args, :outline_character)
    opts = [fill_character: fill_character, outline_character: outline_character]

    id
    |> CanvasRepo.get!()
    |> Canvas.draw_rectangle({x, y}, {w, h}, opts)
    |> CanvasRepo.update()
  end

  def flood_fill(_parent, %{id: id, x: x, y: y, fill_character: fill_character}, _resolution) do
    id
    |> CanvasRepo.get!()
    |> Canvas.flood_fill({x, y}, fill_character: fill_character)
    |> CanvasRepo.update()
  end

  def board(%{board: board}, _, _) do
    {:ok, dumped_board} = EctoBoard.dump(board)
    Jason.encode(dumped_board)
  end
end
