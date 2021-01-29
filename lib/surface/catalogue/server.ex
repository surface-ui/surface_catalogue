defmodule Surface.Catalogue.Server do
  @moduledoc """
  A simple catalogue server that can be used to load catalogues from projects that
  don't initialize their own Phoenix endpoint.

  In case your project already have an endpoint set up, you should provide a new route for
  catalogue instead. See https://github.com/surface-ui/surface_catalogue/#installation for
  details.

  This server is for development only usage.
  """

  defmodule Router do
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

  defmodule Endpoint do
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

    plug Router
  end

  def start(opts \\ []) do
    live_reload_patterns = Keyword.get(opts, :live_reload_patterns, [])

    Application.put_env(:surface_catalogue, __MODULE__.Endpoint,
      url: [host: "localhost"],
      secret_key_base: "Hu4qQN3iKzTV4fJxhorPQlA/osH9fAMtbtjVS58PFgfw3ja5Z18Q/WSNR9wP4OfW",
      live_view: [signing_salt: "hMegieSe"],
      http: [port: System.get_env("PORT") || 4000],
      debug_errors: true,
      check_origin: false,
      pubsub_server: __MODULE__.PubSub,
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
        patterns: live_reload_patterns ++ catalogues_files_patterns()
      ]
    )

    Application.put_env(:phoenix, :serve_endpoints, true)

    Task.start(fn ->
      children = [
        {Phoenix.PubSub, [name: __MODULE__.PubSub, adapter: Phoenix.PubSub.PG2]},
        __MODULE__.Endpoint
      ]

      {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
      Process.sleep(:infinity)
    end)
  end

  defp catalogues_files_patterns do
    mix_project = Mix.Project.get
    if function_exported?(mix_project, :catalogues, 0) do
      mix_project.catalogues() |> Enum.map(&~r[#{Path.join(&1, "")}\/.*(ex)$])
    else
      raise """
      in order to use the Surface Catalogue, you need to define a `catalogues/0` function \
      in your `mix.exs` providing the list catalogues to be loaded.

      Example:

        def catalogues do
          [
            "priv/catalogue",
            "deps/surface/priv/catalogue"
          ]
        end

        defp elixirc_paths(:dev), do: ["lib"] ++ catalogues()
      """
    end
  end
end
