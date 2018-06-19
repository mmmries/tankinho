defmodule Tankinho.Actions do
  defstruct [:fire, :accelerate, :stop, :turn, :turn_gun, :turn_radar, :say, :broadcast]

  def fire(%__MODULE__{}=actions, power), do: %{actions | fire: power}
  def accelerate(%__MODULE__{}=actions, force), do: %{actions | accelerate: force}
  def stop(%__MODULE__{}=actions), do: %{actions | stop: true}
  def turn(%__MODULE__{}=actions, degrees), do: %{actions | turn: degrees}
  def turn_gun(%__MODULE__{}=actions, degrees), do: %{actions | turn_gun: degrees}
  def turn_radar(%__MODULE__{}=actions, degrees), do: %{actions | turn_radar: degrees}
  def say(%__MODULE__{}=actions, message), do: %{actions | say: message}
  def broadcast(%__MODULE__{}=actions, message), do: %{actions | broadcast: message}

  def format_each(%__MODULE__{}=actions) do
    actions
    |> Map.keys()
    |> Enum.map(&( format_action(&1, Map.get(actions, &1)) ))
    |> Enum.reject(&is_nil/1)
  end

  defp format_action(_, nil), do: nil
  defp format_action(:__struct__, _), do: nil
  defp format_action(:accelerate, force), do: "ACCELERATE #{force}"
  defp format_action(:broadcast, msg), do: "BROADCAST #{msg}"
  defp format_action(:fire, power), do: "FIRE #{power}"
  defp format_action(:say, msg), do: "SAY #{msg}"
  defp format_action(:stop, _non_nil), do: "STOP"
  defp format_action(:turn, degrees), do: "TURN #{degrees}"
  defp format_action(:turn_gun, degrees), do: "TURN_GUN #{degrees}"
  defp format_action(:turn_radar, degrees), do: "TURN_RADAR #{degrees}"
end
