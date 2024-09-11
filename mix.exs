defmodule Surface.Catalogue.MixProject do
  use Mix.Project

  @version "0.6.2"

  def project do
    [
      app: :surface_catalogue,
      version: @version,
      elixir: "~> 1.13",
      description: "An initial prototype of the Surface Catalogue",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers() ++ [:surface],
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
    ["priv/catalogue"] ++ surface_catalogue_path()
  end

  defp surface_catalogue_path() do
    Enum.find(deps(), &(elem(&1, 0) == :surface))
    |> surface_dep_opts()
    |> surface_catalogue_path()
  end

  defp surface_catalogue_path(nil), do: []

  defp surface_catalogue_path(opts) do
    path =
      case opts[:path] do
        nil -> "deps/surface"
        surface_dep_path -> Path.expand(surface_dep_path)
      end

    ["#{path}/priv/catalogue"]
  end

  defp surface_dep_opts({:surface, opts}) when is_list(opts), do: opts
  defp surface_dep_opts({:surface, _req, opts}) when is_list(opts), do: opts
  defp surface_dep_opts({:surface, _req}), do: []
  defp surface_dep_opts(_), do: nil

  defp elixirc_paths(:dev), do: ["lib"] ++ catalogues()
  defp elixirc_paths(:test), do: ["lib", "test/support"] ++ catalogues()
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      dev: "run --no-halt dev.exs"
    ]
  end

  defp deps do
    [
      {:surface, "~> 0.10"},
      {:earmark, "~> 1.4.21"},
      {:makeup_elixir, "~> 0.16.0"},
      {:html_entities, "~> 0.4"},
      {:jason, "~> 1.0", only: :dev},
      {:plug_cowboy, "~> 2.0", only: :dev},
      {:esbuild, "~> 0.2", only: :dev},
      {:floki, ">= 0.35.3", only: :test},
      {:phoenix_live_reload, "~> 1.2", optional: true, only: [:prod, :dev]},
      {:ex_doc, ">= 0.31.1", only: :docs}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: "https://github.com/surface-ui/surface_catalogue",
      nest_modules_by_prefix: [Surface.Catalogue],
      extras: [
        "README.md",
        "CHANGELOG.md",
        "LICENSE.md"
      ]
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
