defmodule Sketch.CanvasRepo do
  alias Sketch.Canvas
  alias Sketch.Repo
  import Ecto.Changeset

  @permitted_params [:board, :width, :height]

  def all, do: Repo.all(Canvas)

  def get!(id), do: Repo.get!(Canvas, id)

  def insert!(canvas) do
    canvas
    |> changeset()
    |> Repo.insert!()
  end

  def update(canvas) do
    Canvas
    |> Repo.get(canvas.id)
    |> changeset(Map.from_struct(canvas))
    |> Repo.update()
  end

  def changeset(canvas, attrs \\ %{}) do
    canvas
    |> cast(attrs, @permitted_params)
    |> validate_required(@permitted_params)
  end
end
