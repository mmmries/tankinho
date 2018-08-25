defmodule Mix.Tasks.Tankinho.Start do
  @moduledoc false
  use Mix.Task

  @switches [server: :string, tank_name: :string, tank_module: :string]

  def run(args) do
    {opts, _args, []} = OptionParser.parse(args, switches: @switches)
    tank_module = :"Elixir.#{opts[:tank_module]}"
    {:ok, _} = Tankinho.Client.start_link(%{
      server_addr: Tankinho.parse_server_addr(opts[:server]),
      module: tank_module,
      name: opts[:tank_name],
      port: 0
    })
    IO.puts("Started tank #{opts[:tank_name]}")
    Tankinho.LiveReload.watch_for_changes([__DIR__], [tank_module])
  end
end
