defmodule SketchWeb.CanvasLive do
  use SketchWeb, :live_view

  alias SketchWeb.{Endpoint, Graphql}
  alias Graphql.{Schema, CanvasQueries}
  alias Sketch.{Canvas, CanvasRepo}
  alias Canvas.EctoBoard

  alias Phoenix.Socket.Broadcast

  @impl true
  def mount(_params, _session, socket) do
    subscribe_to_on_canvas_created()

    socket =
      socket
      |> assign(dimensions: {0, 0})
      |> assign(board: %{})
      |> assign(canvas_ids: CanvasRepo.all_ids())

    {:ok, socket}
  end

  defp subscribe_to_on_canvas_created do
    with query <- CanvasQueries.on_canvas_created(),
         {:ok, params} <- Absinthe.run(query, Schema, context: %{pubsub: Endpoint}),
         {:ok, topic} <- Map.fetch(params, "subscribed"),
         :ok <- Endpoint.subscribe(topic) do
      :ok
    end
  end

  defp get_canvas_and_subscribe_to_on_canvas_updated(canvas_id) do
    with %Canvas{} = canvas <- CanvasRepo.get(canvas_id),
         query <- CanvasQueries.on_canvas_updated(canvas_id),
         {:ok, params} <- Absinthe.run(query, Schema, context: %{pubsub: Endpoint}),
         {:ok, topic} <- Map.fetch(params, "subscribed"),
         :ok <- Endpoint.subscribe(topic) do
      {:ok, canvas}
    end
  end

  @impl true
  def handle_info(
        %Broadcast{
          event: "subscription:data",
          payload: %{result: %{data: %{"onCanvasCreated" => response}}}
        } = _broadcast,
        socket
      ) do
    canvas_ids = [response["id"] | socket.assigns.canvas_ids]
    {:noreply, assign(socket, canvas_ids: canvas_ids)}
  end

  def handle_info(
        %Broadcast{
          event: "subscription:data",
          payload: %{result: %{data: %{"onCanvasUpdated" => response}}}
        } = _broadcast,
        socket
      ) do
    {:ok, board} = decode_board(response)
    {:noreply, assign(socket, board: board)}
  end

  @impl true
  def handle_params(%{"id" => canvas_id}, _uri, socket) do
    subscribe_to_on_canvas_created()
    {:ok, canvas} = get_canvas_and_subscribe_to_on_canvas_updated(canvas_id)

    socket =
      socket
      |> assign(dimensions: {canvas.width, canvas.height})
      |> assign(board: canvas.board)
      |> assign(canvas_ids: CanvasRepo.all_ids())

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def as_rows(board, {_w, _h}) do
    for x <- 0..(24 - 1) do
      for y <- 0..(24 - 1) do
        board[{x, y}]
      end
    end
  end

  defp decode_board(%{"board" => board} = _response) do
    with {:ok, board} <- Jason.decode(board),
         {:ok, board} <- EctoBoard.load(board) do
      {:ok, board}
    else
      error -> error
    end
  end
end
