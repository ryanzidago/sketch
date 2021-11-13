defmodule EctoBoard do
  use Ecto.Type

  def type, do: :map

  def cast(board) when is_map(board) and not is_struct(board) do
    {:ok, board}
  end

  def cast(_), do: :error

  def load(board) when is_map(board) do
    board =
      for {xy, character} <- board, reduce: %{} do
        acc when is_binary(xy) ->
          [x, y] = String.split(xy, ",")
          x = String.to_integer(x)
          y = String.to_integer(y)

          Map.put(acc, {x, y}, character)
      end

    {:ok, board}
  end

  def dump(board) when is_map(board) do
    board =
      if board["0, 0"] do
        board
      else
        for {{x, y}, character} <- board, reduce: %{} do
          acc -> Map.put(acc, "#{x},#{y}", character)
        end
      end

    {:ok, board}
  end

  def dump(_), do: :error
end

defmodule Sketch.Canvases.Canvas do
  use Ecto.Schema

  alias Sketch.Repo
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "canvases" do
    field :board, EctoBoard
    field :width, :integer
    field :height, :integer

    timestamps()
  end

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
