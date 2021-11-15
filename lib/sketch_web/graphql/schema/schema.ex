defmodule SketchWeb.Graphql.Schema do
  use Absinthe.Schema

  alias SketchWeb.Graphql.CanvasResolver

  object :canvas do
    field :id, :id
    field :board, :string, resolve: &CanvasResolver.board/3
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
      arg(:fill_character, non_null(:string))

      resolve(&CanvasResolver.flood_fill/3)
    end
  end

  subscription do
    field :on_canvas_created, :canvas do
      config(fn _args, _context ->
        {:ok, topic: "*"}
      end)

      trigger(:create_canvas, topic: fn _args -> "*" end)
    end

    field :on_canvas_updated, :canvas do
      arg(:id, non_null(:id))

      config(fn args, _context ->
        {:ok, topic: "canvas:#{args.id}"}
      end)

      trigger(:draw_rectangle,
        topic: fn
          args -> "canvas:#{args.id}"
        end
      )

      trigger(:flood_fill,
        topic: fn
          args -> "canvas:#{args.id}"
        end
      )
    end
  end
end
