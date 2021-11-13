defmodule Sketch.Canva do
  defguard is_within_canva(x, y) when x in 0..(24 - 1) and y in 0..(24 - 1)

  def new do
    for x <- 0..(24 - 1), y <- 0..(24 - 1), into: %{}, do: {{x, y}, " "}
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

  def pretty_print(canva) do
    pretty_canva =
      for x <- 0..(25 - 1), into: "" do
        row =
          for y <- 0..(25 - 1), into: "" do
            "#{canva[{x, y}]}"
          end

        row <> "\n"
      end

    IO.puts(pretty_canva)
  end

  def pretty(canva) do
    for x <- 0..(25 - 1), into: "" do
      row =
        for y <- 0..(25 - 1), into: "" do
          "#{canva[{x, y}]}"
        end

      row <> "\n"
    end
  end
end
