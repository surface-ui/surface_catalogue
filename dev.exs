# iex -S mix dev
Logger.configure(level: :debug)

# Configures the endpoint
Application.put_env(:surface_catalogue, DemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Hu4qQN3iKzTV4fJxhorPQlA/osH9fAMtbtjVS58PFgfw3ja5Z18Q/WSNR9wP4OfW",
  live_view: [signing_salt: "hMegieSe"],
  http: [port: System.get_env("PORT") || 4444],
  debug_errors: true,
  check_origin: false,
  pubsub_server: Demo.PubSub,
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
      ~r"lib/surface/catalogue/(live|components)/.*(ex)$",
      ~r"priv/catalogue/.*(ex)$"
    ]
  ]
)

defmodule DemoWeb.Router do
  use Phoenix.Router
  import Surface.Catalogue.Router

  pipeline :browser do
    plug :fetch_session
  end

  scope "/" do
    pipe_through :browser
    surface_catalogue "/"
  end
end

defmodule DemoWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :surface_catalogue

  socket "/live", Phoenix.LiveView.Socket
  socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket

  plug Phoenix.LiveReloader
  plug Phoenix.CodeReloader

  plug Plug.Static,
    at: "/",
    from: :surface_catalogue,
    gzip: false,
    only: ~w(css js)

  plug Plug.Session,
    store: :cookie,
    key: "_live_view_key",
    signing_salt: "/VEDsdfsffMnp5"

  plug Plug.RequestId

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug DemoWeb.Router
end

Application.put_env(:phoenix, :serve_endpoints, true)

Task.start(fn ->
  children = [
    {Phoenix.PubSub, [name: Demo.PubSub, adapter: Phoenix.PubSub.PG2]},
    DemoWeb.Endpoint
  ]

  {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
  Process.sleep(:infinity)
end)
