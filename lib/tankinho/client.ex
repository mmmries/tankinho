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

  # REGD
  # this is an ACK for our registration
  def handle_info({:udp, _, _, _, "REGD"}, %{status: :registering}=state) do
    Logger.info "Registered as #{state.name}"
    state = %{state | status: :registered}
    {:noreply, state}
  end
  # START_GAME 1600x1024 60
  # game_widthxgame_height tank_size
  def handle_info({:udp, _, _, _, "START_GAME"<>_}, %{status: :registered}=state) do
    Logger.info "Joining Game"
    state = %{state | status: :playing}
    {:noreply, state}
  end
  # STATUS {"energy":100,"gun_heading":356,"heading":356,"radar_heading":356,"time":0,"speed":0,"x":1627,"y":1627,"robot_scanned":[],"broadcasts_received":[]}
  # a status update about the game, time to send in your move
  def handle_info({:udp, _, _, _, "STATUS "<>_json}, %{status: :playing, addr: {addr,port}}=state) do
    :ok = :gen_udp.send(state.socket, addr, port, "FIRE 0.2")
    {:noreply, state}
  end
  # GAME_OVER
  # the game is over
  def handle_info({:udp, _, _, _, "GAME_OVER"}, %{status: :playing}=state) do
    Logger.info "Game Over, Man!"
    {:noreply, %{state | status: :registered}}
  end

  def handle_info(other, state) do
    Logger.error "#{__MODULE__} unexpected message (status=#{state.status}) #{inspect other}"
    {:noreply, state}
  end
end
