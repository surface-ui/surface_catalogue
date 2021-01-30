# iex -S mix dev

Logger.configure(level: :debug)

Surface.Catalogue.Server.start(
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      System.get_env("NODE_ENV") || "production",
      "--watch-stdin",
      cd: "assets"
    ]
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/surface/catalogue/(live|components)/.*(ex)$"
    ]
  ]
)
