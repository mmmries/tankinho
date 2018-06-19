defmodule Tankinho.Client do
  use GenServer
  alias Tankinho.Protocol

  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  def init(%{server_addr: addr, name: name, port: port, module: module}) do
    {:ok, udp} = :gen_udp.open(port, [:binary])
    protocol = Protocol.init(name, module, addr, udp)
    {:ok, protocol}
  end

  def handle_info(message, protocol) do
    protocol = Protocol.handle_info(protocol, message)
    {:noreply, protocol}
  end
end
