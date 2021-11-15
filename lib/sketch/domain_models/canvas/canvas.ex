defmodule Sketch.Canvas do
  @moduledoc """
  `Sketch.Canvas` is used to create new canvases and draw on them.
  """
  use Ecto.Schema

  alias Sketch.Canvas.EctoBoard

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "canvases" do
    field :board, EctoBoard
    field :width, :integer
    field :height, :integer

    timestamps()
  end

  @doc """
  Returns `true` if the given coordinates `x`, `y` are within the canvas.
  """
  defguard is_within_canvas(canvas, x, y)
           when x in 0..canvas.width and y in 0..canvas.height

  @doc """
  Returns `true` if the given `character` is a 1-byte bitstring.
  """
  defguard is_ascii(character) when is_bitstring(character) and byte_size(character) == 1

  @doc """
  Creates a new canvas.
  """
  def new(board_size \\ {24, 24})

  def new({w, h}) when w > 100 or h > 100 do
    {:error, "Dimension exceeds maximum board size (100 * 100"}
  end

  def new({w, h}) when w < 2 or h < 2 do
    {:error, "Dimensions must be at least 2 * 2"}
  end

  def new({w, h}) do
    board = for x <- 0..(h - 1), y <- 0..(w - 1), into: %{}, do: {{x, y}, " "}
    %__MODULE__{board: board, width: w, height: h}
  end

  def draw_rectangle(%__MODULE__{} = canvas, {x, y}, {_w, _h}, _opts)
      when not is_within_canvas(canvas, x, y) do
    {:error, "Coordinates outside of the board's surface"}
  end

  @doc """
  Draws a rectangle on the given canvas, at position `x`, `y` whose width is `w` and height is `h`, with either a `fill_character` and/or an `outline_character`.
  """
  def draw_rectangle(%__MODULE__{} = canvas, {x, y}, {w, h}, _opts)
      when not is_within_canvas(canvas, x + w, y + h) do
    {:error, "Drawing outside of the board is not allowed"}
  end

  def draw_rectangle(%__MODULE__{} = canvas, {x, y}, {w, h}, opts)
      when is_within_canvas(canvas, x, y)
      when is_within_canvas(canvas, w, h) do
    fill_character = Keyword.get(opts, :fill_character)
    outline_character = Keyword.get(opts, :outline_character)

    case {fill_character, outline_character, is_ascii(fill_character),
          is_ascii(outline_character)} do
      {nil, nil, _, _} ->
        {:error, "No fill_character or outline_character provided"}

      {fill_character, nil, true, _} ->
        draw_rectangle_with_single_character(canvas, {x, y}, {w, h}, character: fill_character)

      {nil, outline_character, _, true} ->
        draw_rectangle_with_outline_character(canvas, {x, y}, {w, h}, character: outline_character)

      {_fill_character, _outline_character, true, true} ->
        canvas
        |> draw_rectangle_with_single_character({x, y}, {w, h}, character: fill_character)
        |> draw_rectangle_with_outline_character({x, y}, {w, h}, character: outline_character)

      {_, _, _, _} ->
        {:error, "Character is not an ASCII encoded byte"}
    end
  end

  @doc """
  Flood fills cells starting from position `x`, `y`. Stops as soon as a cell is already filled with a non empty character.
  `flood_fill/3` uses breadth-first search with the built-in Erlang `:queue` module to "circle" around the coordinates.

  """
  def flood_fill(%__MODULE__{} = _canvas, {_x, _y}, []) do
    {:error, "No fill_character provided"}
  end

  def flood_fill(%__MODULE__{} = canvas, {x, y}, _opts)
      when not is_within_canvas(canvas, x + 1, y + 1) do
    {:error, "Coordinates outside of the board's surface"}
  end

  def flood_fill(%__MODULE__{} = _canvas, {_x, _y}, fill_character: fill_character)
      when not is_ascii(fill_character) do
    {:error, "Character is not an ASCII encoded byte"}
  end

  def flood_fill(%__MODULE__{} = canvas, {x, y}, fill_character: fill_character)
      when is_within_canvas(canvas, x, y) do
    do_flood_fill(canvas, [{x, y}], MapSet.new(), fill_character: fill_character)
  end

  @doc """
  Pretty prints the canvas' board.
  """
  def pretty_print(%__MODULE__{board: board, width: w, height: h}) do
    pretty_canvas =
      for x <- 0..(h - 1), into: "" do
        row =
          for y <- 0..(w - 1), into: "" do
            "#{board[{x, y}]}"
          end

        row <> "\n"
      end

    IO.puts(pretty_canvas)
  end

  @doc """
  Returns a pretty string representation of the canvas' board.
  """
  def pretty(%__MODULE__{board: board, width: w, height: h}) do
    for x <- 0..(h - 1), into: "" do
      row =
        for y <- 0..(w - 1), into: "" do
          "#{board[{x, y}]}"
        end

      row <> "\n"
    end
  end

  defp draw_rectangle_with_single_character(
         %__MODULE__{board: board} = canvas,
         {x, y},
         {w, h},
         character: character
       ) do
    cells_to_be_filled = for y <- y..(h - 1 + y), x <- x..(w - 1 + x), do: {y, x}
    board = draw_on_board(board, cells_to_be_filled, character: character)
    %__MODULE__{canvas | board: board}
  end

  defp draw_rectangle_with_outline_character(
         %__MODULE__{board: board} = canvas,
         {x, y},
         {w, h},
         character: character
       ) do
    board =
      for n <- 0..(w - 1), reduce: board do
        board -> Map.put(board, {y, x + n}, character)
      end

    board =
      for n <- 0..(h - 1), reduce: board do
        board -> Map.put(board, {y + n, x + w - 1}, character)
      end

    board =
      for n <- 0..(w - 1), reduce: board do
        board -> Map.put(board, {y + h - 1, x + n}, character)
      end

    board =
      for n <- 0..(h - 1), reduce: board do
        board -> Map.put(board, {y + n, x}, character)
      end

    %__MODULE__{canvas | board: board}
  end

  defp draw_on_board(board, [], _opts), do: board

  defp draw_on_board(board, [{x, y} | cells_to_be_filled], character: character) do
    board = Map.put(board, {x, y}, character)
    draw_on_board(board, cells_to_be_filled, character: character)
  end

  defp do_flood_fill(%__MODULE__{} = canvas, [] = _stack, _visited, _opts) do
    canvas
  end

  defp do_flood_fill(%__MODULE__{} = canvas, stack, visited, opts) do
    {board, stack, visited} =
      Enum.reduce(stack, {canvas.board, stack, visited}, fn
        _, {board, [coordinates | stack], visited} ->
          if MapSet.member?(visited, coordinates) do
            {board, stack, visited}
          else
            board = fill(board, coordinates, opts)

            [up, right, down, left] = neighbours({canvas.width, canvas.height}, coordinates)

            visited = MapSet.put(visited, coordinates)

            up = if board[up] == " ", do: up
            right = if board[right] == " ", do: right
            down = if board[down] == " ", do: down
            left = if board[left] == " ", do: left

            stack = if up, do: [up | stack], else: stack
            stack = if right, do: [right | stack], else: stack
            stack = if down, do: [down | stack], else: stack
            stack = if left, do: [left | stack], else: stack

            {board, stack, visited}
          end
      end)

    do_flood_fill(%__MODULE__{canvas | board: board}, stack, visited, opts)
  end

  defp fill(board, {x, y}, opts) do
    fill_character = Keyword.get(opts, :fill_character)
    if board[{x, y}] == " ", do: Map.put(board, {x, y}, fill_character), else: board
  end

  defp neighbours({_w, _h} = board_dimension, {_x, _y} = coordinates) do
    up = if can_go_up?(board_dimension, coordinates), do: up(coordinates)
    right = if can_go_right?(board_dimension, coordinates), do: right(coordinates)
    down = if can_go_down?(board_dimension, coordinates), do: down(coordinates)
    left = if can_go_left?(board_dimension, coordinates), do: left(coordinates)

    [up, right, down, left]
  end

  defp can_go_up?({_w, _h}, {_x, y}), do: y > 0
  defp up({x, y}), do: {x, y - 1}

  defp can_go_right?({_w, h}, {x, _y}), do: x < h - 1
  defp right({x, y}), do: {x + 1, y}

  defp can_go_down?({w, _h}, {_x, y}), do: y < w - 1
  defp down({x, y}), do: {x, y + 1}

  defp can_go_left?({_w, _h}, {x, _y}), do: x > 0
  defp left({x, y}), do: {x - 1, y}
end
