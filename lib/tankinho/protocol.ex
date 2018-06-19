defmodule Tankinho.Protocol do
  defstruct [:game_state, :module, :name, :server, :status, :udp_port]
  alias Tankinho.Actions

  def init(name, module, server_addr, udp_port) do
    send self(), :register
    %__MODULE__{
      module: module,
      name: name,
      server: server_addr,
      status: :registering,
      udp_port: udp_port,
    }
  end

  def handle_info(%__MODULE__{}=state, :register) do
    :ok = send_to_server(state, "REG #{state.name}")
    Process.send_after(self(), :register, 2_000)
    state
  end

  def handle_packet(%__MODULE__{status: :registering}=state, "REGD") do
    %{state | status: :registered}
  end
  def handle_packet(%__MODULE__{}=state, "REGD"), do: state
  def handle_packet(%__MODULE__{}=state, "ALIVE?") do
    :ok = send_to_server(state, "ALIVE")
    state
  end
  def handle_packet(%__MODULE__{}=state, "START_GAME "<>settings) do
    [width, height, size] = settings |> String.split([" ","x"]) |> Enum.map(&String.to_integer/1)
    settings = %{width: width, height: height, size: size}
    game_state = apply(state.module, :init, [settings])
    %{ state | status: :playing, game_state: game_state }
  end
  def handle_packet(%__MODULE__{status: :playing}=state, "STATUS "<>json) do
    events = Jason.decode!(json)
    {actions, game_state} = apply(state.module, :tick, [events, state.game_state])
    actions |> Actions.format_each |> Enum.each(fn(msg) -> send_to_server(state, msg) end)
    %{ state | game_state: game_state }
  end
  def handle_packet(%__MODULE__{}=state, "GAME_OVER") do
    %{ state | game_state: nil, status: :registered }
  end

  defp send_to_server(%{server: {addr, port}, udp_port: udp}, message) do
    :gen_udp.send(udp, addr, port, message)
  end
end
