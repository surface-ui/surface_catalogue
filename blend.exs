%{
  local: [
    {:surface, path: "../surface"}
  ],
  github: [
    {:surface, github: "surface-ui/surface"}
  ],
  lowest: [
    {:surface, "0.10.0"},
    {:earmark, "1.4.21"},
    {:makeup_elixir, "0.16.0"},
    {:html_entities, "0.4.0"},
    {:jason, "1.0.0", optional: true, override: true},
    {:plug_cowboy, "2.3.0", only: :dev},
    {:esbuild, "0.2.0", only: :dev},
    {:floki, "0.35.3", only: :test},
    {:phoenix_live_reload, "1.2.0", optional: true, only: [:prod, :dev]},
    {:ex_doc, "0.31.1", only: :docs}
  ]
}
