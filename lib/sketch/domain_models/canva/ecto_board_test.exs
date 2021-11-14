defmodule Sketch.Canvas.EctoBoardTest do
  use Sketch.DataCase

  alias Sketch.Canvas
  alias Sketch.Canvas.EctoBoard

  describe "type/0" do
    test "returns :map" do
      assert EctoBoard.type() == :map
    end
  end

  describe "cast/1" do
    test "{:ok, board}` without modifying the board, when the board param is a map (but not a struct)" do
      assert %Canvas{board: board} = Canvas.new()
      assert {:ok, board} == EctoBoard.cast(board)
    end

    test "returns `:error` in other cases" do
      assert canvas = Canvas.new()
      assert :error == EctoBoard.cast(canvas)
    end
  end

  describe "load/1" do
    test "changes the board's keys from a string to a `{x, y}` Tuple, where x and y are integers" do
      board = %{"0,0" => "X", "0,1" => "X", "1,0" => "X", "1,1" => "X"}

      assert {:ok, board} = EctoBoard.load(board)

      assert Map.has_key?(board, {0, 0})
      assert Map.has_key?(board, {0, 1})
      assert Map.has_key?(board, {1, 0})
      assert Map.has_key?(board, {1, 1})
    end
  end

  describe "dump/1" do
    test "changes the board's key from a two element tuple to a string" do
      board = %{{0, 0} => "X", {0, 1} => "X", {1, 0} => "X", {1, 1} => "X"}

      assert {:ok, board} = EctoBoard.dump(board)

      assert Map.has_key?(board, "0,0")
      assert Map.has_key?(board, "0,1")
      assert Map.has_key?(board, "1,0")
      assert Map.has_key?(board, "1,1")
    end
  end
end
