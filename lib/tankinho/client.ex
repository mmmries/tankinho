defmodule Tankinho.Client do
  use GenServer
  require Logger

  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  def init(%{server_addr: addr, name: name}) do
    {:ok, udp} = :gen_udp.open(5567, [:binary])
    send self(), :register
    {:ok, %{addr: addr, name: name, status: :registering, socket: udp}}
  end

  def handle_info(:register, %{status: :registering, addr: {addr, port}}=state) do
    :ok = :gen_udp.send(state.socket, addr, port, "REG #{state.name}")
    Process.send_after(self(), :register, 2_000)
    {:noreply, state}
  end
  def handle_info(:register, state), do: {:noreply, state}

  def handle_info({:udp, _, _, _, "REGD"}, %{status: :registering}=state) do
    Logger.info "Registered as #{state.name}"
    state = %{state | status: :registered}
    {:noreply, state}
  end

  def handle_info(other, state) do
    Logger.error "#{__MODULE__} unexpected message #{inspect other}"
    {:noreply, state}
  end
end