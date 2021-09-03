# iex -S mix dev

Logger.configure(level: :error)

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

alias Surface.Catalogue.Screenshotter

base_url = "http://localhost:4000/examples"

Screenshotter.screenshot_examples(base_url: base_url)
