if File.exists?("blend/premix.exs") do
  Code.compile_file("blend/premix.exs")
else
  defmodule Blend.Premix do
    def patch_project(project), do: project
    def patch_deps(deps), do: deps
  end
end

defmodule Surface.Catalogue.MixProject do
  use Mix.Project

  @version "0.6.3"
  @source_url "https://github.com/surface-ui/surface_catalogue"
  @homepage_url "https://surface-ui.org"

  def project do
    [
      app: :surface_catalogue,
      version: @version,
      elixir: "~> 1.13",
      description: "An initial prototype of the Surface Catalogue",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers() ++ [:surface],
      aliases: aliases(),
      xref: [exclude: Surface.Catalogue.Playground],
      deps: deps(),
      preferred_cli_env: [docs: :docs],
      # Docs
      name: "Surface Catalogue",
      source_url: @source_url,
      homepage_url: @homepage_url,
      docs: docs(),
      package: package()
    ]
    |> Blend.Premix.patch_project()
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Surface.Catalogue.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:dev), do: ["lib"] ++ catalogues()
  defp elixirc_paths(:test), do: ["lib", "test/support"] ++ catalogues()
  defp elixirc_paths(_), do: ["lib"]

  def catalogues do
    ["priv/catalogue"] ++ surface_catalogue_path()
  end

  defp surface_catalogue_path() do
    deps()
    |> List.keyfind!(:surface, 0)
    |> surface_dep_opts()
    |> surface_catalogue_path()
  end

  defp surface_catalogue_path(nil), do: []

  defp surface_catalogue_path(opts) do
    path =
      case opts[:path] do
        nil -> Mix.Project.deps_path() |> Path.relative() |> Path.join("/surface")
        surface_dep_path -> Path.expand(surface_dep_path)
      end

    ["#{path}/priv/catalogue"]
  end

  defp surface_dep_opts({:surface, opts}) when is_list(opts), do: opts
  defp surface_dep_opts({:surface, _req, opts}) when is_list(opts), do: opts
  defp surface_dep_opts({:surface, _req}), do: []
  defp surface_dep_opts(_), do: nil

  defp aliases do
    [
      dev: "run --no-halt dev.exs"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:surface, "~> 0.10"},
      {:earmark, "~> 1.4.21"},
      {:makeup_elixir, "~> 0.16.0 or ~> 1.0"},
      {:html_entities, "~> 0.4"},
      {:jason, "~> 1.0", only: :dev},
      {:plug_cowboy, "~> 2.3", only: :dev},
      {:esbuild, "~> 0.2", only: :dev},
      {:blend, "~> 0.4.0", only: :dev},
      {:floki, ">= 0.35.3", only: :test},
      {:phoenix_live_reload, "~> 1.2", optional: true, only: [:prod, :dev]},
      {:ex_doc, ">= 0.31.1", only: :docs}
    ]
    |> Blend.Premix.patch_deps()
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
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
      links: %{
        Website: @homepage_url,
        Changelog: "https://hexdocs.pm/surface_catalogue/changelog.html",
        GitHub: @source_url
      },
      files: ~w(
          README.md
          CHANGELOG.md
          LICENSE.md
          mix.exs
          lib
          assets
          priv/catalogue
        )
    }
  end
end
