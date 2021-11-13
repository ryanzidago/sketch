defmodule SketchWeb.Schema do
  use Absinthe.Schema

  alias Sketch.Canvases.Canvas.EctoBoard
  alias SketchWeb.CanvasResolver

  object :canvas do
    field :id, :id
    field :board, :string, resolve: &resolve_board/3
    field :width, :integer
    field :height, :integer
    field :inserted_at, :string
    field :updated_at, :string
  end

  query do
    @desc "Get all canvases"
    field :canvases, list_of(:canvas) do
      resolve(&CanvasResolver.all/3)
    end

    @desc "Get a canvas"
    field :canvas, :canvas do
      arg(:id, non_null(:id))

      resolve(&CanvasResolver.get/3)
    end
  end

  mutation do
    @desc "Creates a canvas"
    field :create_canvas, type: :canvas do
      arg(:width, :integer)
      arg(:height, :integer)

      resolve(&CanvasResolver.create_canvas/3)
    end

    @desc "Draws a rectangle"
    field :draw_rectangle, type: :canvas do
      arg(:id, non_null(:id))
      arg(:x, non_null(:integer))
      arg(:y, non_null(:integer))
      arg(:width, non_null(:integer))
      arg(:height, non_null(:integer))
      arg(:fill_character, :string)
      arg(:outline_character, :string)

      resolve(&CanvasResolver.draw_rectangle/3)
    end

    @desc "Flood fills the canvas"
    field :flood_fill, type: :canvas do
      arg(:id, non_null(:id))
      arg(:x, non_null(:integer))
      arg(:y, non_null(:integer))
      arg(:fill_character, :string)

      resolve(&CanvasResolver.flood_fill/3)
    end
  end

  defp resolve_board(%{board: board}, _, _) do
    {:ok, dumped_board} = EctoBoard.dump(board)
    Jason.encode(dumped_board)
  end
end
