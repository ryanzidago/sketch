defmodule Sketch.Repo.Migrations.CreateCanvasesTable do
  use Ecto.Migration

  def change do
    create table :canvases, primary_key: false do
      add :id, :uuid, primary_key: true
      add :board, :map, null: false
      add :width, :integer, null: false
      add :height, :integer, null: false

      timestamps()
    end
  end
end
