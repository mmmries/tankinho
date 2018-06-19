defmodule Tankinho.Protocol do
  defstruct [:name, :server, :status, :udp_port]

  def init(name, server_addr, udp_port) do
    send self(), :register
    %__MODULE__{
      name: name,
      server: server_addr,
      status: :registering,
      udp_port: udp_port,
    }
  end

  def handle_info(state, :register) do
    :ok = send_to_server(state, "REG #{state.name}")
    Process.send_after(self(), :register, 2_000)
    state
  end

  def handle_packet(%{status: :registering}=state, "REGD") do
    %{state | status: :registered}
  end
  def handle_packet(state, "REGD"), do: state
  def handle_packet(state, "ALIVE?") do
    :ok = send_to_server(state, "ALIVE")
  end

  defp send_to_server(%{server: {addr, port}, udp_port: udp}, message) do
    :gen_udp.send(udp, addr, port, message)
  end
end
