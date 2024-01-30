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
      surface_catalogue("/catalogue")
    end
  end

  defmodule ErrorView do
    use Phoenix.Template,
      root: "lib/surface/catalogue/templates",
      namespace: Surface.Catalogue

    def template_not_found(template, _assigns) do
      Phoenix.Controller.status_message_from_template(template)
    end
  end

  defmodule Endpoint do
    use Phoenix.Endpoint, otp_app: :surface_catalogue

    socket "/live", Phoenix.LiveView.Socket

    if code_reloading? do
      socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket

      plug Phoenix.LiveReloader
      plug Phoenix.CodeReloader
    end

    plug Plug.Static,
      at: "/",
      from: :surface_catalogue,
      gzip: false,
      only: ~w(assets)

    plug Plug.Session,
      store: :cookie,
      key: "_live_view_key",
      signing_salt: "/VEDsdfsffMnp5"

    plug Plug.RequestId

    plug Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json],
      pass: ["*/*"],
      json_decoder: Jason

    plug Router
  end

  def start(opts \\ []) do
    default_opts = [
      url: [host: "localhost"],
      secret_key_base: "Hu4qQN3iKzTV4fJxhorPQlA/osH9fAMtbtjVS58PFgfw3ja5Z18Q/WSNR9wP4OfW",
      live_view: [signing_salt: "hMegieSe"],
      http: [port: System.get_env("PORT") || 4000],
      render_errors: [view: ErrorView],
      check_origin: false,
      pubsub_server: __MODULE__.PubSub,
      live_reload: [
        patterns: catalogues_files_patterns()
      ]
    ]

    Application.put_env(:surface_catalogue, __MODULE__.Endpoint, merge_opts(default_opts, opts))
    Application.put_env(:phoenix, :serve_endpoints, true)

    Task.start(fn ->
      children = [
        {Phoenix.PubSub, [name: __MODULE__.PubSub, adapter: Phoenix.PubSub.PG2]},
        {__MODULE__.Endpoint, [log_access_url: false]}
      ]

      {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
      require Logger
      Logger.info("Access Surface Catalogue at #{__MODULE__.Endpoint.url()}/catalogue")
      Process.sleep(:infinity)
    end)
  end

  defp catalogues_files_patterns do
    mix_project = Mix.Project.get()

    if function_exported?(mix_project, :catalogues, 0) do
      Enum.flat_map(mix_project.catalogues(), fn path ->
        path = Path.join(path, "")
        [~r[#{path}\/.*(ex)$], ~r[#{path}\/.*(js|css|png|jpeg|jpg|gif|svg)$]]
      end)
    else
      raise """
      in order to use the catalogue server, you need to define a public `catalogues/0` \
      function in your `mix.exs` providing the list catalogues to be loaded.

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

  defp merge_opts(default_opts, opts) do
    Keyword.merge(default_opts, opts, fn
      :live_reload, lr1, lr2 ->
        Keyword.merge(lr1, lr2, fn
          :patterns, p1, p2 ->
            p1 ++ p2

          _, _p1, p2 ->
            p2
        end)

      _, _lr1, lr2 ->
        lr2
    end)
  end
end
