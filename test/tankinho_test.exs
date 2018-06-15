defmodule TankinhoTest do
  use ExUnit.Case
  doctest Tankinho

  test "greets the world" do
    assert Tankinho.hello() == :world
  end
end
