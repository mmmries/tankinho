defmodule Tankinho.MixProject do
  use Mix.Project

  def project do
    [
      app: :tankinho,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.0"},
      {:file_system, "~> 0.2"},
    ]
  end
end
