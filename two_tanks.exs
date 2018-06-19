[server_addr] = System.argv()
server_addr = Tankinho.parse_server_addr(server_addr)

defmodule ShrinkingViolet do
  alias Tankinho.Actions

  def init(_game_settings) do
    %{turn_rate: :rand.uniform(30) - 15}
  end

  def tick(_events, %{turn_rate: rate}=state) do
    actions = %Actions{} |> Actions.turn(rate)
    {actions, state}
  end
end

{:ok, _} = Tankinho.Client.start_link(%{
  server_addr: server_addr,
  module: ShrinkingViolet,
  name: "tank1",
  port: 5567,
})
{:ok, _} = Tankinho.Client.start_link(%{
  server_addr: server_addr,
  module: ShrinkingViolet,
  name: "tank2",
  port: 5568,
})
Process.sleep(1_000_000_000)
