options = case System.argv() do
            [server_addr, name] ->
              [addr: Tankinho.parse_server_addr(server_addr), name: name]
            [server_addr, name, port] ->
              [addr: Tankinho.parse_server_addr(server_addr), name: name, port: String.to_integer(port)]
            _ ->
              IO.puts "Please provide the address of the server and a name for your bot"
              IO.puts "\teg. mix run client.exs 192.168.0.5:5566 Rusty"
              IO.puts ""
              IO.puts "You can also optionally specify which port you want to bind to"
              IO.puts "\teg. mix run client.exs 192.168.0.5:5566 Rusty 5577"
              exit(:normal)
          end

Code.require_file("my_tank.ex")

{:ok, _} = Tankinho.Client.start_link(%{
  server_addr: Keyword.get(options, :addr),
  module: MyTank,
  name: Keyword.get(options, :name),
  port: Keyword.get(options, :port, 5567),
})
IO.puts "Started #{Keyword.get(options, :name)}"
Tankinho.LiveReload.watch_for_changes([__DIR__], [MyTank])
