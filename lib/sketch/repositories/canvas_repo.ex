defmodule Sketch.CanvasRepo do
  alias Sketch.Canvas
  alias Sketch.Repo
  import Ecto.Changeset

  @permitted_params [:board, :width, :height]

  def all, do: Repo.all(Canvas)

  def get(id) do
    case Ecto.UUID.dump(id) do
      :error -> {:error, "ID must be a UUID"}
      {:ok, _id} -> Repo.get(Canvas, id)
    end
  end

  def insert!(canvas) do
    canvas
    |> changeset()
    |> Repo.insert!()
  end

  def insert(canvas) do
    canvas
    |> changeset()
    |> Repo.insert()
  end

  def update(canvas) do
    Canvas
    |> Repo.get(canvas.id)
    |> changeset(Map.from_struct(canvas), [:board])
    |> Repo.update()
  end

  defp changeset(canvas, attrs \\ %{}, permitted_params \\ @permitted_params) do
    canvas
    |> cast(attrs, permitted_params)
    |> validate_required(permitted_params)
  end
end
