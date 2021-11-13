defmodule Sketch.Canvas do
  defguard is_within_canvas(x, y) when x in 0..(24 - 1) and y in 0..(24 - 1)

  def new({w, h} \\ {24, 24}) do
    for x <- 0..(h - 1), y <- 0..(w - 1), into: %{}, do: {{x, y}, " "}
  end

  def draw_rectangle(canvas, {x, y}, {w, h}, opts)
      when is_within_canvas(x, y)
      when is_within_canvas(w, h) do
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

  defp draw_rectangle_with_single_character(canvas, {x, y}, {w, h}, character: character) do
    cells_to_be_filled = for y <- y..(h - 1 + y), x <- x..(w - 1 + x), do: {y, x}
    draw_on_canvas(canvas, cells_to_be_filled, character: character)
  end

  defp draw_rectangle_with_outline_character(canvas, {x, y}, {w, h}, character: character) do
    canvas =
      for n <- 0..(w - 1), reduce: canvas do
        canvas -> Map.put(canvas, {y, x + n}, character)
      end

    canvas =
      for n <- 0..(h - 1), reduce: canvas do
        canvas -> Map.put(canvas, {y + n, x + w - 1}, character)
      end

    canvas =
      for n <- 0..(w - 1), reduce: canvas do
        canvas -> Map.put(canvas, {y + h - 1, x + n}, character)
      end

    canvas =
      for n <- 0..(h - 1), reduce: canvas do
        canvas -> Map.put(canvas, {y + n, x}, character)
      end

    canvas
  end

  defp draw_on_canvas(canvas, _cells_to_be_filled, opts)

  defp draw_on_canvas(canvas, [], _opts), do: canvas

  defp draw_on_canvas(canvas, [{x, y} | cells_to_be_filled], character: character) do
    canvas = Map.put(canvas, {x, y}, character)
    draw_on_canvas(canvas, cells_to_be_filled, character: character)
  end

  def flood_fill(canvas, {x, y}, opts) do
    queue = :queue.new()
    queue = :queue.in({x, y}, queue)

    do_flood_fill(canvas, queue, MapSet.new(), [], opts)
  end

  defp do_flood_fill(canvas, {[], []}, _visited, _result, _opts), do: canvas

  defp do_flood_fill(canvas, queue, visited, result, opts) do
    {canvas, queue, visited, result} =
      Enum.reduce(1..:queue.len(queue), {canvas, queue, visited, result}, fn _n,
                                                                             {canvas, queue,
                                                                              visited, result} ->
        {{:value, coordinates}, queue} = :queue.out(queue)

        if MapSet.member?(visited, coordinates) do
          {canvas, queue, visited, result}
        else
          canvas = fill(canvas, coordinates, opts)
          [up, right, down, left] = neighbours = neighbours(coordinates)
          result = [neighbours | result]

          visited = MapSet.put(visited, coordinates)

          up = if canvas[up] == " " && up not in visited, do: up
          right = if canvas[right] == " " && right not in visited, do: right
          down = if canvas[down] == " " && down not in visited, do: down
          left = if canvas[left] == " " && left not in visited, do: left

          queue = if up, do: :queue.in(up, queue), else: queue
          queue = if right, do: :queue.in(right, queue), else: queue
          queue = if down, do: :queue.in(down, queue), else: queue
          queue = if left, do: :queue.in(left, queue), else: queue

          {canvas, queue, visited, result}
        end
      end)

    do_flood_fill(canvas, queue, visited, result, opts)
  end

  defp fill(canvas, {x, y}, opts) do
    fill_character = Keyword.get(opts, :fill_character)
    if canvas[{x, y}] == " ", do: Map.put(canvas, {x, y}, fill_character), else: canvas
  end

  defp neighbours(coordinates) do
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

  def pretty_print(canvas) do
    pretty_canvas =
      for x <- 0..(24 - 1), into: "" do
        row =
          for y <- 0..(24 - 1), into: "" do
            "#{canvas[{x, y}]}"
          end

        row <> "\n"
      end

    IO.puts(pretty_canvas)
  end

  def pretty(canvas) do
    for x <- 0..(24 - 1), into: "" do
      row =
        for y <- 0..(24 - 1), into: "" do
          "#{canvas[{x, y}]}"
        end

      row <> "\n"
    end
  end
end
