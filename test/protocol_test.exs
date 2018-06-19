defmodule Tankinho.ProtocolTest do
  use ExUnit.Case
  alias Tankinho.Protocol

  defmodule TestTank do
    alias Tankinho.Actions
    import Tankinho.Actions

    def init(game_settings) do
      Map.put(game_settings, :foo, "bar")
    end

    def tick(_events, state) do
      actions = %Actions{}
                |> fire(1)
      state = Map.put(state, :foo, "baz")
      {actions, state}
    end
  end

  setup do
    {:ok, server_udp} = :gen_udp.open(5566, [:binary])
    {:ok, client_udp} = :gen_udp.open(5567, [:binary])
    {:ok, %{client_udp: client_udp, server_udp: server_udp}}
  end

  test "when starting we prompt ourself to send a registration" do
    state = Protocol.init("player1", TestTank, {{127,0,0,1}, 5566}, :fake_udp_port)
    assert_received :register
    assert state.game_state == nil
    assert state.name == "player1"
    assert state.server == {{127,0,0,1}, 5566}
    assert state.status == :registering
    assert state.udp_port == :fake_udp_port
  end

  test "when registering we send a message to the server",
  %{client_udp: client, server_udp: server} do
    Protocol.init("player1", TestTank, {{127,0,0,1}, 5566}, client)
    |> Protocol.handle_info(:register)
    assert_receive {:udp, ^server, _, _, "REG player1"}
  end

  test "when we get back a REGD message while registering" do
    state = Protocol.init("player1", TestTank, {{127,0,0,1}, 5566}, :fake_udp_port)
            |> Protocol.handle_packet("REGD")
    assert state.status == :registered
  end

  test "when we get back a REGD message during a game" do
    state = Protocol.init("player1", TestTank, {{127,0,0,1}, 5566}, :fake_udp_port)
            |> Map.put(:status, :playing)
            |> Protocol.handle_packet("REGD")
    assert state.status == :playing
  end

  test "we respond to aliveness checks",
  %{client_udp: client, server_udp: server} do
    Protocol.init("player1", TestTank, {{127,0,0,1}, 5566}, client)
    |> Protocol.handle_packet("ALIVE?")
    assert_receive {:udp, ^server, _, _, "ALIVE"}
  end

  test "when a game starts we call the init/1 function on our game module to initialize the game_state" do
    state = Protocol.init("player1", TestTank, {{127,0,0,1}, 5566}, :fake_udp_port)
            |> Map.put(:status, :playing)
            |> Protocol.handle_packet("START_GAME 1600x1024 60")
    assert state.status == :playing
    assert state.game_state == %{width: 1600, height: 1024, size: 60, foo: "bar"}
  end

  test "when the game sends and update it calls tick/2 and sends actions back to the server",
  %{server_udp: server, client_udp: client} do
    update_json = %{
      energy: 100,
      gun_heading: 300,
      heading: 300,
      radar_heading: 300,
      time: 1,
      speed: 0,
      x: 800,
      y: 512,
      robots_scanned: [],
      broadcasts: [],
    } |> Jason.encode!
    state = Protocol.init("player1", TestTank, {{127,0,0,1}, 5566}, client)
            |> Protocol.handle_packet("START_GAME 1600x1024 60")
            |> Protocol.handle_packet("STATUS #{update_json}")

    assert state.game_state.foo == "baz"
    assert state.status == :playing
    assert_receive {:udp, ^server, _, _, "FIRE 1"}
  end
end
