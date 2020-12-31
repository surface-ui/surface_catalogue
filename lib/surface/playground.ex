defmodule Surface.Playground do
  @moduledoc """
  A playground live view for external catalogues.
  """

  import Phoenix.LiveView

  @default_config [
    head: """
    <link phx-track-static rel="stylesheet" href="/css/app.css"/>
    <script defer type="module" src="/js/app.js"></script>
    """
  ]

  defmacro __using__(opts) do
    {opts, config} = Keyword.split(opts, [:namespace, :container, :layout])
    subject = Keyword.fetch!(config, :subject)

    quote do
      use Surface.LiveView, unquote(opts)

      alias unquote(subject)
      require Surface.Catalogue.Data, as: Data

      @config unquote(config)
      @before_compile unquote(__MODULE__)

      @impl true
      def mount(params, session, socket) do
        unquote(__MODULE__).__mount__(params, session, socket, unquote(subject))
      end

      @impl true
      def handle_info(message, socket) do
        unquote(__MODULE__).__handle_info__(message, socket)
      end
    end
  end

  def get_window_id(session, params) do
    key = "__window_id__"

    get_value_by_key(session, key) ||
      get_value_by_key(params, key) ||
      Base.encode16(:crypto.strong_rand_bytes(16))
  end

  defmacro __before_compile__(env) do
    user_config = Module.get_attribute(env.module, :config)

    catalogue_config =
      user_config
      |> Keyword.get(:catalogue)
      |> Surface.Catalogue.Util.get_catalogue_config()

    config =
      @default_config
      |> Keyword.merge(catalogue_config)
      |> Keyword.merge(user_config)

    subject = Keyword.fetch!(user_config, :subject)

    module_doc =
      quote do
        @moduledoc catalogue: [
          subject: unquote(subject),
          config: unquote(config)
        ]
      end

    if Module.defines?(env.module, {:handle_event, 3}) do
      quote do
        unquote(module_doc)

        defoverridable handle_event: 3

        @impl true
        def handle_event(event, value, socket) do
          result = super(event, value, socket)
          socket =
            case result do
              {:noreply, socket} -> socket
              {:reply, _map, socket} -> socket
            end

          unquote(__MODULE__).__handle_event__(event, value, socket)
          result
        end
      end
    else
      quote do
        unquote(module_doc)

        @impl true
        def handle_event(event, value, socket) do
          unquote(__MODULE__).__handle_event__(event, value, socket)
        end
      end
    end
  end

  @doc false
  def __mount__(params, session, socket, subject) do
    window_id = get_window_id(session, params)
    socket = assign(socket, :__window_id__, window_id)

    if connected?(socket) do
      {events, props} =
        subject.__props__()
        |> Enum.split_with(fn prop -> prop.type == :event end)

      events_props_values = generate_events_props(events)
      props_values_with_events = Map.merge(socket.assigns.props, events_props_values)

      Phoenix.PubSub.broadcast(
        Surface.Catalogue.PubSub,
        "Surface.Catalogue:#{window_id}",
        {:playground_init, self(), subject, props, events, props_values_with_events}
      )
      {:ok, assign(socket, :props, props_values_with_events)}
    else
      {:ok, socket}
    end
  end

  @doc false
  def __handle_info__({:update_props, values}, socket) do
    {:noreply, assign(socket, :props, values)}
  end

  def __handle_info__(:wake_up, socket) do
    {:noreply, socket}
  end

  @doc false
  def __handle_event__(event, value, socket) do
    window_id = socket.assigns[:__window_id__]

    Phoenix.PubSub.broadcast(
      Surface.Catalogue.PubSub,
      "Surface.Catalogue:#{window_id}",
      {:playground_event_received, event, value, socket.assigns.props}
    )

    {:noreply, socket}
  end

  defp get_value_by_key(map, key) when is_map(map) do
    map[key]
  end

  defp get_value_by_key(_map, _key) do
    nil
  end

  defp generate_events_props(events) do
    for %{name: name} <- events, into: %{} do
      {name, %{name: name, target: :live_view}}
    end
  end
end
