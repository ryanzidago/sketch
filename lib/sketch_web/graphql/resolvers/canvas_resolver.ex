defmodule SketchWeb.Graphql.CanvasResolver do
  alias Sketch.{Canvas, CanvasRepo}
  alias Canvas.EctoBoard

  def all(_parent, _args, _resolution) do
    {:ok, CanvasRepo.all()}
  end

  def get(_parent, %{id: id}, _resolution) do
    with %Canvas{} = canvas <- CanvasRepo.get(id) do
      {:ok, canvas}
    else
      error -> error
    end
  end

  def create_canvas(_parents, %{width: width, height: height}, _resolution) do
    with %Canvas{} = canvas <- Canvas.new({width, height}),
         {:ok, canvas} <- CanvasRepo.insert(canvas) do
      {:ok, canvas}
    else
      error -> error
    end
  end

  def create_canvas(_parents, _args, _resolution) do
    with %Canvas{} = canvas <- Canvas.new(),
         {:ok, canvas} <- CanvasRepo.insert(canvas) do
      {:ok, canvas}
    else
      error -> error
    end
  end

  def draw_rectangle(_parent, %{id: id, x: x, y: y, width: w, height: h} = args, _resolution) do
    fill_character = Map.get(args, :fill_character)
    outline_character = Map.get(args, :outline_character)
    opts = [fill_character: fill_character, outline_character: outline_character]

    with %Canvas{} = canvas <- CanvasRepo.get(id),
         %Canvas{} = canvas <- Canvas.draw_rectangle(canvas, {x, y}, {w, h}, opts),
         {:ok, canvas} <- CanvasRepo.update(canvas) do
      {:ok, canvas}
    else
      error -> error
    end
  end

  def flood_fill(_parent, %{id: id, x: x, y: y, fill_character: fill_character}, _resolution) do
    with %Canvas{} = canvas <- CanvasRepo.get(id),
         %Canvas{} = canvas <- Canvas.flood_fill(canvas, {x, y}, fill_character: fill_character),
         {:ok, canvas} <- CanvasRepo.update(canvas) do
      {:ok, canvas}
    else
      error -> error
    end
  end

  def board(%{board: board}, _, _) do
    {:ok, dumped_board} = EctoBoard.dump(board)
    Jason.encode(dumped_board)
  end
end
