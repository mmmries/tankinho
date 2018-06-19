defmodule Tankinho.ProtocolTest do
  use ExUnit.Case
  alias Tankinho.Protocol

  setup do
    {:ok, server_udp} = :gen_udp.open(5566, [:binary])
    {:ok, client_udp} = :gen_udp.open(5567, [:binary])
    {:ok, %{client_udp: client_udp, server_udp: server_udp}}
  end

  test "when starting we prompt ourself to send a registration" do
    state = Protocol.init("player1", {{127,0,0,1}, 5566}, :fake_udp_port)
    assert_received :register
    assert state.name == "player1"
    assert state.server == {{127,0,0,1}, 5566}
    assert state.status == :registering
    assert state.udp_port == :fake_udp_port
  end

  test "when registering we send a message to the server",
  %{client_udp: client, server_udp: server} do
    Protocol.init("player1", {{127,0,0,1}, 5566}, client)
    |> Protocol.handle_info(:register)
    assert_receive {:udp, ^server, _, _, "REG player1"}
  end

  test "when we get back a REGD message while registering" do
    state = Protocol.init("player1", {{127,0,0,1}, 5566}, :fake_udp_port)
            |> Protocol.handle_packet("REGD")
    assert state.status == :registered
  end

  test "when we get back a REGD message during a game" do
    state = Protocol.init("player1", {{127,0,0,1}, 5566}, :fake_udp_port)
            |> Map.put(:status, :playing)
            |> Protocol.handle_packet("REGD")
    assert state.status == :playing
  end

  test "we respond to aliveness checks",
  %{client_udp: client, server_udp: server} do
    Protocol.init("player1", {{127,0,0,1}, 5566}, client)
    |> Protocol.handle_packet("ALIVE?")
    assert_receive {:udp, ^server, _, _, "ALIVE"}
  end
end
