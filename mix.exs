defmodule Surface.Catalogue.MixProject do
  use Mix.Project

  def project do
    [
      app: :surface_catalogue,
      version: "0.1.0",
      elixir: "~> 1.8",
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {Surface.Catalogue.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"],
      dev: "run --no-halt dev.exs"
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.0"},
      {:html_entities, "~> 0.4"},
      {:plug_cowboy, "~> 2.0", only: :dev},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:surface, path: "../surface", override: true}
    ]
  end
end
