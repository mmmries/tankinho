{opts, _args, []} = OptionParser.parse(System.argv(), switches: [server: :string, port: :integer, name: :string, tank_file: :string, tank_name: :string])

if !Keyword.has_key?(opts, :server) || !Keyword.has_key?(opts, :name) do
  IO.puts "Please provide the address of the server and a name for your bot"
  IO.puts "\teg. mix run --server 192.168.0.5:5566 --name Jill"
  IO.puts ""
  IO.puts "Other Options"
  IO.puts "\t--port PORT the port number you want your client to bind to (default 5567)"
  IO.puts "\t--tank-file FILE the file that defines your tank behavior (default MyTank.ex)"
  IO.puts "\t--tank-name Name the module name of your tank behavior (default the basename of your tank file)"
  exit(:normal)
end

server_addr = opts |> Keyword.get(:server) |> Tankinho.parse_server_addr()
name = opts |> Keyword.get(:name)
port = opts |> Keyword.get(:port, 5567)
tank_file = opts |> Keyword.get(:tank_file, "MyTank.ex")
tank_name = opts |> Keyword.get(:tank_name, Path.basename(tank_file, ".ex"))
tank_module = :"Elixir.#{tank_name}"

Code.require_file(tank_file)

{:ok, _} = Tankinho.Client.start_link(%{
  server_addr: server_addr,
  module: tank_module,
  name: name,
  port: port,
})
IO.puts "Started #{name}:#{port}"
Tankinho.LiveReload.watch_for_changes([__DIR__], [tank_module])
