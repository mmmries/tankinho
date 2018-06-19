options = case System.argv() do
            [server_addr, name] ->
              [addr: Tankinho.parse_server_addr(server_addr), name: name]
            [server_addr, name, port] ->
              [addr: Tankinho.parse_server_addr(server_addr), name: name, port: String.to_integer(port)]
            true ->
              IO.puts "Please provide the address of the server and a name for your bot"
              IO.puts "\teg. mix run client.exs 192.168.0.5:5566 Rusty"
              IO.puts ""
              IO.puts "You can also optionally specify which port you want to bind to"
              IO.puts "\teg. mix run client.exs 192.168.0.5:5566 Rusty 5577"
              exit(:normal)
          end

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

{:ok, _} = Tankinho.Client.start_link(%{
  server_addr: Keyword.get(options, :addr),
  module: MyTank,
  name: Keyword.get(options, :name),
  port: Keyword.get(options, :port, 5567),
})
IO.puts "Started #{Keyword.get(options, :name)}"
Process.sleep(1_000_000_000)
