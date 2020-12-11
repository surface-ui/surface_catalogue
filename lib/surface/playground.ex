defmodule Surface.Playground do
  @moduledoc """
  A playground live view for external catalogues.
  """

  import Phoenix.LiveView

  @default_head """
  <link phx-track-static rel="stylesheet" href="/css/app.css"/>
  """

  defmacro __using__(opts) do
    subject = Keyword.fetch!(opts, :subject)
    head = Keyword.get(opts, :head, @default_head)
    style = Keyword.get(opts, :style)
    class = Keyword.get(opts, :class)

    quote do
      use Surface.LiveView

      alias unquote(subject)

      @moduledoc catalogue: [
                   head: unquote(head),
                   style: unquote(style),
                   class: unquote(class)
                 ]

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
    if Module.defines?(env.module, {:handle_event, 3}) do
      quote do
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
      Phoenix.PubSub.broadcast(
        Surface.Catalogue.PubSub,
        "Surface.Catalogue:#{window_id}",
        {:playground_init, self(), subject, socket.assigns.props}
      )
    end

    {:ok, socket}
  end

  @doc false
  def __handle_info__({:update_props, props}, socket) do
    {:noreply, assign(socket, :props, props)}
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
end
