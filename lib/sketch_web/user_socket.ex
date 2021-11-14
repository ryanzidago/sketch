defmodule SketchWeb.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: SketchWeb.Schema

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
