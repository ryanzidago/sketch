defmodule SketchWeb.Schema.SubscriptionTest do
  use SketchWeb.SubscriptionCase

  alias Sketch.{Canvas, CanvasRepo}

  setup do
    canvas = CanvasRepo.insert!(Canvas.new())

    {
      :ok,
      canvas: canvas
    }
  end

  describe "onCanvasCreated" do
    test "pushes a newly created canvas to the subscribers", %{socket: socket} do
      ref = push_doc(socket, on_canvas_created_subscription())
      assert_reply(ref, :ok, %{subscriptionId: subscription_id})
      ref = push_doc(socket, create_canvas_with_default_size_mutation())

      assert_reply(ref, :ok, reply)
      assert %{data: %{"createCanvas" => %{"id" => canvas_id}}} = reply

      assert_push("subscription:data", push)

      assert _expected =
               %{
                 result: %{
                   data: %{
                     "onCanvasCreated" => %{
                       "id" => ^canvas_id,
                       "height" => 24,
                       "width" => 24
                     }
                   }
                 },
                 subscriptionId: ^subscription_id
               } = push

      assert CanvasRepo.get!(canvas_id)
    end
  end

  describe "onCanvasUpdated" do
    test "pushes an updated canvas to the subscribers", %{
      socket: socket,
      canvas: %{id: canvas_id} = _canvas
    } do
      ref = push_doc(socket, on_canvas_updated_subscription(canvas_id))
      assert_reply(ref, _, %{subscriptionId: subscription_id})

      ref =
        push_doc(socket, draw_rectangle_mutation(),
          variables: %{
            id: canvas_id,
            x: 0,
            y: 0,
            width: 8,
            height: 3,
            fill_character: "X",
            outline_character: "O"
          }
        )

      assert_reply(ref, :ok, reply)
      assert %{data: %{"drawRectangle" => %{"id" => ^canvas_id}}} = reply
      assert_push("subscription:data", push)

      assert _expected =
               %{
                 result: %{
                   data: %{
                     "onCanvasUpdated" => %{
                       "board" => _board,
                       "height" => 24,
                       "width" => 24,
                       "id" => ^canvas_id
                     }
                   }
                 },
                 subscriptionId: ^subscription_id
               } = push
    end
  end

  defp create_canvas_with_default_size_mutation do
    """
    mutation CreateCanvas {
      createCanvas {
        id
      }
    }
    """
  end

  defp draw_rectangle_mutation do
    """
    mutation DrawRectangle($id: ID!, $x: Int!, $y: Int!, $width: Int!, $height: Int!, $fill_character: String!, $outline_character: String!) {
      drawRectangle(id: $id, x: $x, y: $y, width: $width, height: $height, fillCharacter: $fill_character, outlineCharacter: $outline_character) {
        id
      }
    }
    """
  end

  defp on_canvas_created_subscription do
    """
    subscription {
      onCanvasCreated {
        id
        width
        height
      }
    }
    """
  end

  defp on_canvas_updated_subscription(id) do
    """
    subscription {
      onCanvasUpdated(id: \"#{id}\") {
        id
        width
        height
        board
      }
    }
    """
  end
end
