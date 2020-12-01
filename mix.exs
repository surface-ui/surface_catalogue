defmodule Surface.Catalogue.MixProject do
  use Mix.Project

  def project do
    [
      app: :surface_catalogue,
      version: "0.1.0",
      elixir: "~> 1.8",
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Surface.Catalogue.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.0"},
      {:html_entities, "~> 0.4"},
      {:surface, "~> 0.1.1"}
    ]
  end
end
