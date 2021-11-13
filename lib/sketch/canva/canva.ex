defmodule Sketch.Canva do
  defguard is_within_canva(x, y) when x in 0..(24 - 1) and y in 0..(24 - 1)

  def new({w, h} \\ {24, 24}) do
    for x <- 0..(h - 1), y <- 0..(w - 1), into: %{}, do: {{x, y}, " "}
  end

  def draw_rectangle(canva, {x, y}, {w, h}, opts)
      when is_within_canva(x, y)
      when is_within_canva(w, h) do
    fill_character = Keyword.get(opts, :fill_character)
    outline_character = Keyword.get(opts, :outline_character)

    case {fill_character, outline_character} do
      {nil, nil} ->
        {:error, "No fill or outline character selected"}

      {fill_character, nil} ->
        draw_rectangle_with_single_character(canva, {x, y}, {w, h}, character: fill_character)

      {nil, outline_character} ->
        draw_rectangle_with_outline_character(canva, {x, y}, {w, h}, character: outline_character)

      {_fill_character, _outline_character} ->
        canva
        |> draw_rectangle_with_single_character({x, y}, {w, h}, character: fill_character)
        |> draw_rectangle_with_outline_character({x, y}, {w, h}, character: outline_character)
    end
  end

  defp draw_rectangle_with_single_character(canva, {x, y}, {w, h}, character: character) do
    cells_to_be_filled = for y <- y..(h - 1 + y), x <- x..(w - 1 + x), do: {y, x}
    draw_on_canva(canva, cells_to_be_filled, character: character)
  end

  defp draw_rectangle_with_outline_character(canva, {x, y}, {w, h}, character: character) do
    canva =
      for n <- 0..(w - 1), reduce: canva do
        canva -> Map.put(canva, {y, x + n}, character)
      end

    canva =
      for n <- 0..(h - 1), reduce: canva do
        canva -> Map.put(canva, {y + n, x + w - 1}, character)
      end

    canva =
      for n <- 0..(w - 1), reduce: canva do
        canva -> Map.put(canva, {y + h - 1, x + n}, character)
      end

    canva =
      for n <- 0..(h - 1), reduce: canva do
        canva -> Map.put(canva, {y + n, x}, character)
      end

    canva
  end

  defp draw_on_canva(canva, _cells_to_be_filled, opts)

  defp draw_on_canva(canva, [], _opts), do: canva

  defp draw_on_canva(canva, [{x, y} | cells_to_be_filled], character: character) do
    canva = Map.put(canva, {x, y}, character)
    draw_on_canva(canva, cells_to_be_filled, character: character)
  end

  def flood_fill(canva, {x, y}, opts) do
    queue = :queue.new()
    queue = :queue.in({x, y}, queue)

    do_flood_fill(canva, queue, MapSet.new(), [], opts)
  end

  defp do_flood_fill(canva, {[], []}, _visited, _result, _opts), do: canva

  defp do_flood_fill(canva, queue, visited, result, opts) do
    {canva, queue, visited, result} =
      Enum.reduce(1..:queue.len(queue), {canva, queue, visited, result}, fn _n,
                                                                            {canva, queue,
                                                                             visited, result} ->
        {{:value, coordinates}, queue} = :queue.out(queue)

        if MapSet.member?(visited, coordinates) do
          {canva, queue, visited, result}
        else
          canva = fill(canva, coordinates, opts)
          [up, right, down, left] = neighbours = neighbours(coordinates)
          result = [neighbours | result]

          visited = MapSet.put(visited, coordinates)

          up = if canva[up] == " " && up not in visited, do: up
          right = if canva[right] == " " && right not in visited, do: right
          down = if canva[down] == " " && down not in visited, do: down
          left = if canva[left] == " " && left not in visited, do: left

          queue = if up, do: :queue.in(up, queue), else: queue
          queue = if right, do: :queue.in(right, queue), else: queue
          queue = if down, do: :queue.in(down, queue), else: queue
          queue = if left, do: :queue.in(left, queue), else: queue

          {canva, queue, visited, result}
        end
      end)

    do_flood_fill(canva, queue, visited, result, opts)
  end

  defp fill(canva, {x, y}, opts) do
    fill_character = Keyword.get(opts, :fill_character)
    if canva[{x, y}] == " ", do: Map.put(canva, {x, y}, fill_character), else: canva
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

  def pretty_print(canva) do
    pretty_canva =
      for x <- 0..(24 - 1), into: "" do
        row =
          for y <- 0..(24 - 1), into: "" do
            "#{canva[{x, y}]}"
          end

        row <> "\n"
      end

    IO.puts(pretty_canva)
  end

  def pretty(canva) do
    for x <- 0..(24 - 1), into: "" do
      row =
        for y <- 0..(24 - 1), into: "" do
          "#{canva[{x, y}]}"
        end

      row <> "\n"
    end
  end
end
