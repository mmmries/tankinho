defmodule Tankinho.ActionsTest do
  use ExUnit.Case
  alias Tankinho.Actions

  test "format_each skips actions the client didn't specify" do
    actions = %Actions{} |> Actions.fire(1) |> Actions.stop()
    assert Actions.format_each(actions) == ["FIRE 1", "STOP"]
  end

  test "it can format all the different kinds of actions" do
    import Actions
    actions = %Actions{}
              |> fire(2)
              |> accelerate(-1)
              |> stop()
              |> turn(-10)
              |> turn_gun(15)
              |> turn_radar(-33)
              |> say("ohai")
              |> broadcast("marco")
    assert Actions.format_each(actions) == [
      "ACCELERATE -1",
      "BROADCAST marco",
      "FIRE 2",
      "SAY ohai",
      "STOP",
      "TURN -10",
      "TURN_GUN 15",
      "TURN_RADAR -33",
    ]
  end
end
