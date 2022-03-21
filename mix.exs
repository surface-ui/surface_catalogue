defmodule Surface.Catalogue.MixProject do
  use Mix.Project

  @version "0.4.1"

  def project do
    [
      app: :surface_catalogue,
      version: @version,
      elixir: "~> 1.8",
      description: "An initial prototype of the Surface Catalogue",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      aliases: aliases(),
      xref: [exclude: Surface.Catalogue.Playground],
      package: package()
    ]
  end

  def application do
    [
      mod: {Surface.Catalogue.Application, []},
      extra_applications: [:logger]
    ]
  end

  def catalogues do
    [
      "priv/catalogue",
      "deps/surface/priv/catalogue"
    ]
  end

  defp elixirc_paths(:dev), do: ["lib"] ++ catalogues()
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      dev: "run --no-halt dev.exs"
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.0"},
      {:html_entities, "~> 0.4"},
      {:plug_cowboy, "~> 2.0"},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:surface, "~> 0.7.0"},
      {:earmark, "~>1.4.21"},
      {:ex_doc, ">= 0.19.0", only: :docs},
      {:makeup_elixir, "~> 0.15.1"}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      source_url: "https://github.com/surface-ui/surface_catalogue"
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/surface-ui/surface_catalogue"},
      files:
        ~w(assets lib priv) ++
          ~w(CHANGELOG.md LICENSE.md mix.exs README.md)
    }
  end
end
