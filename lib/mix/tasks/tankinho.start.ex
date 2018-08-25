defmodule Mix.Tasks.Tankinho.Start do
  @moduledoc false
  use Mix.Task

  @required_options [:server, :tank_name, :tank_module]
  @switches [server: :string, tank_name: :string, tank_module: :string]

  def run(args) do
    Mix.Task.run("app.start")
    {opts, _args, []} = OptionParser.parse(args, switches: @switches)
    check_for_required_options!(opts)
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

  defp check_for_required_options!(opts) do
    unless Enum.all?(@required_options, &(Keyword.has_key?(opts, &1))) do
      print_usage()
      exit(:normal)
    end
  end

  defp print_usage do
    IO.puts """
    Usage

      mix tankinho.start --server 127.0.0.1:5566 --tank-name Tank48 --tank_module Tankinho.ExampleTanks.Spinner

    Options

      --server <ip>:<port>   Host & port running rrobots server
      --tank-name <name>     A display name for the tank
      --tank-module <module> The module containing behavior for the tank
    """
  end
end
