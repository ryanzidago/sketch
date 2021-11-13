defmodule Sketch.Canvases.Canvas do
  use Ecto.Schema

  alias Sketch.Repo
  alias Sketch.Canvases.Canvas.EctoBoard
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "canvases" do
    field :board, EctoBoard
    field :width, :integer
    field :height, :integer

    timestamps()
  end

  def all, do: Repo.all(__MODULE__)

  def get!(id), do: Repo.get!(__MODULE__, id)

  def insert!(canvas, attrs \\ %{}) do
    canvas
    |> changeset(attrs)
    |> Repo.insert!()
  end

  def update!(canvas, attrs) do
    canvas
    |> changeset(attrs)
    |> Repo.update!()
  end

  defp changeset(canvas, attrs) when is_struct(attrs) do
    attrs = Map.from_struct(attrs)
    do_changeset(canvas, attrs)
  end

  defp changeset(canvas, attrs) when is_map(attrs) do
    do_changeset(canvas, attrs)
  end

  defp do_changeset(canvas, attrs) do
    canvas
    |> cast(attrs, [:board, :width, :height])
    |> validate_required([:board, :width, :height])
  end
end
