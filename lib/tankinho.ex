defmodule Tankinho do
  @doc """
  Parse a string server address into a IPv4 address + port number

  ## Examples

      iex> Tankinho.parse_server_addr("127.0.0.1:5566")
      {{127,0,0,1}, 5566}

  """
  def parse_server_addr(str) do
    [addr, port] = str |> String.split(":")
    [p1, p2, p3, p4] = addr |> String.split(".") |> Enum.map(&String.to_integer/1)
    {{p1, p2, p3, p4}, String.to_integer(port)}
  end
end
