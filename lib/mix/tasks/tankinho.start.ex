defmodule Mix.Tasks.Tankinho.Start do
  use Mix.Task

  @shortdoc "Starts a tank"

  @moduledoc """
  Usage

      mix tankinho.start --server 127.0.0.1:5566 --name Tank48 --tank Tankinho.ExampleTanks.Spinner

  Options

      --server <ip>:<port> Host & port running rrobots server

      --name <name>        A display name for the tank

      --tank <module>      The module containing behavior for the tank
  """

  @required_options [:server, :name, :tank]
  @switches [server: :string, name: :string, tank: :string]

  def run(args) do
    Mix.Task.run("app.start")
    {opts, _args, []} = OptionParser.parse(args, switches: @switches)
    check_for_required_options!(opts)
    tank_module = :"Elixir.#{opts[:tank]}"

    {:ok, _} =
      Tankinho.Client.start_link(%{
        server_addr: Tankinho.parse_server_addr(opts[:server]),
        module: tank_module,
        name: opts[:name],
        port: 0
      })

    IO.puts("Started tank #{opts[:name]} from module #{opts[:tank]}")
    Tankinho.LiveReload.watch_for_changes([__DIR__], [tank_module])
  end

  defp check_for_required_options!(opts) do
    unless Enum.all?(@required_options, &Keyword.has_key?(opts, &1)) do
      print_usage()
      exit(:normal)
    end
  end

  defp print_usage do
    IO.puts(@moduledoc)
  end
end
