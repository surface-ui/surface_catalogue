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
      {:surface, git: "https://github.com/msaraiva/surface.git", tag: "v0.1.0-rc.2"}
    ]
  end
end
