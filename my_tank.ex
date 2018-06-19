defmodule MyTank do
  alias Tankinho.Actions

  def init(_game_settings) do
    %{turn_rate: :rand.uniform(30) - 15}
  end

  def tick(_events, %{turn_rate: rate}=state) do
    actions = %Actions{} |> Actions.turn(rate) |> Actions.fire(0.25)
    {actions, state}
  end
end
