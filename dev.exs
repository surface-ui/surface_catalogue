# iex -S mix dev

Logger.configure(level: :debug)

Surface.Catalogue.Server.start(
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]}
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/surface/catalogue/(live|components)/.*(ex)$",
      ~r"priv/catalogue/.*(ex)$"
    ]
  ]
)
