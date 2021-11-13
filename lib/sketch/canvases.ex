defmodule Sketch.Canvases do
  alias Sketch.Canvases.Canvas

  defguard is_within_board(x, y) when x in 0..(24 - 1) and y in 0..(24 - 1)

  def new({w, h} \\ {24, 24}) do
    board = for x <- 0..(h - 1), y <- 0..(w - 1), into: %{}, do: {{x, y}, " "}
    %Canvas{board: board, width: w, height: h}
  end

  def draw_rectangle(%Canvas{} = canvas, {x, y}, {w, h}, opts)
      when is_within_board(x, y)
      when is_within_board(w, h) do
    fill_character = Keyword.get(opts, :fill_character)
    outline_character = Keyword.get(opts, :outline_character)

    case {fill_character, outline_character} do
      {nil, nil} ->
        {:error, "No fill or outline character selected"}

      {fill_character, nil} ->
        draw_rectangle_with_single_character(canvas, {x, y}, {w, h}, character: fill_character)

      {nil, outline_character} ->
        draw_rectangle_with_outline_character(canvas, {x, y}, {w, h}, character: outline_character)

      {_fill_character, _outline_character} ->
        canvas
        |> draw_rectangle_with_single_character({x, y}, {w, h}, character: fill_character)
        |> draw_rectangle_with_outline_character({x, y}, {w, h}, character: outline_character)
    end
  end

  defp draw_rectangle_with_single_character(
         %Canvas{board: board} = canvas,
         {x, y},
         {w, h},
         character: character
       ) do
    cells_to_be_filled = for y <- y..(h - 1 + y), x <- x..(w - 1 + x), do: {y, x}
    board = draw_on_board(board, cells_to_be_filled, character: character)
    %Canvas{canvas | board: board}
  end

  defp draw_rectangle_with_outline_character(
         %Canvas{board: board} = canvas,
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

    %Canvas{canvas | board: board}
  end

  defp draw_on_board(board, [], _opts), do: board

  defp draw_on_board(board, [{x, y} | cells_to_be_filled], character: character) do
    board = Map.put(board, {x, y}, character)
    draw_on_board(board, cells_to_be_filled, character: character)
  end

  def flood_fill(%Canvas{board: board} = canvas, {x, y}, opts) do
    queue = :queue.new()
    queue = :queue.in({x, y}, queue)

    board = do_flood_fill(board, queue, MapSet.new(), [], opts)
    %Canvas{canvas | board: board}
  end

  defp do_flood_fill(board, {[], []}, _visited, _result, _opts), do: board

  defp do_flood_fill(board, queue, visited, result, opts) do
    {board, queue, visited, result} =
      Enum.reduce(1..:queue.len(queue), {board, queue, visited, result}, fn _n,
                                                                            {board, queue,
                                                                             visited, result} ->
        {{:value, coordinates}, queue} = :queue.out(queue)

        if MapSet.member?(visited, coordinates) do
          {board, queue, visited, result}
        else
          board = fill(board, coordinates, opts)
          [up, right, down, left] = neighbours = neighbours(coordinates)
          result = [neighbours | result]

          visited = MapSet.put(visited, coordinates)

          up = if board[up] == " " && up not in visited, do: up
          right = if board[right] == " " && right not in visited, do: right
          down = if board[down] == " " && down not in visited, do: down
          left = if board[left] == " " && left not in visited, do: left

          queue = if up, do: :queue.in(up, queue), else: queue
          queue = if right, do: :queue.in(right, queue), else: queue
          queue = if down, do: :queue.in(down, queue), else: queue
          queue = if left, do: :queue.in(left, queue), else: queue

          {board, queue, visited, result}
        end
      end)

    do_flood_fill(board, queue, visited, result, opts)
  end

  defp fill(board, {x, y}, opts) do
    fill_character = Keyword.get(opts, :fill_character)
    if board[{x, y}] == " ", do: Map.put(board, {x, y}, fill_character), else: board
  end

  defp neighbours({_x, _y} = coordinates) do
    up = if can_go_up?(coordinates), do: up(coordinates)
    right = if can_go_right?(coordinates), do: right(coordinates)
    down = if can_go_down?(coordinates), do: down(coordinates)
    left = if can_go_left?(coordinates), do: left(coordinates)

    [up, right, down, left]
  end

  defp can_go_up?({_x, y}), do: y > 0
  defp up({x, y}), do: {x, y - 1}

  defp can_go_right?({x, _y}), do: x < 25 - 1
  defp right({x, y}), do: {x + 1, y}

  defp can_go_down?({_x, y}), do: y < 25 - 1
  defp down({x, y}), do: {x, y + 1}

  defp can_go_left?({x, _y}), do: x > 0
  defp left({x, y}), do: {x - 1, y}

  def pretty_print(%Canvas{board: board, width: w, height: h}) do
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

  def pretty(%Canvas{board: board, width: w, height: h}) do
    for x <- 0..(h - 1), into: "" do
      row =
        for y <- 0..(w - 1), into: "" do
          "#{board[{x, y}]}"
        end

      row <> "\n"
    end
  end
end
