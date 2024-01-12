import Config

config :phoenix, :json_library, Jason
config :phoenix, :stacktrace_depth, 20

config :logger, level: :warning
config :logger, :console, format: "[$level] $message\n"

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.13.8",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# When running `mix dev` inside `surface_catalogue`, there's no need to have the
# assets in "/assets/catalogue" as they are the same we already have in `/assets`.
config :surface_catalogue, :assets_path, "/assets"

if Mix.env() == :dev do
  # Required at compile time
  config :surface_catalogue, Surface.Catalogue.Server.Endpoint,
    code_reloader: true,
    debug_errors: true
end
