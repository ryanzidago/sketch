defmodule SketchWeb.SubscriptionCase do
  @moduledoc """
  This moduel defines the test case to be used by GraphQL subscription tests
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use SketchWeb.ChannelCase
      use Absinthe.Phoenix.SubscriptionTest, schema: SketchWeb.Graphql.Schema

      setup do
        {:ok, socket} = Phoenix.ChannelTest.connect(SketchWeb.UserSocket, %{})
        {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)
        {:ok, socket: socket}
      end
    end
  end
end
