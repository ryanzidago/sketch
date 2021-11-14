defmodule Sketch.Canvas.EctoBoard do
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
