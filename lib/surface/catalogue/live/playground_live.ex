defmodule Surface.Catalogue.PlaygroundLive do
  use Surface.LiveView

  alias Surface.Catalogue.Util

  data playground, :module
  data head, :string
  data __window_id__, :string

  def mount(params, session, socket) do
    window_id = Util.get_window_id(session, params)
    socket = assign(socket, :__window_id__, window_id)
    {:ok, socket, temporary_assigns: [event_log_entries: []]}
  end

  def handle_params(params, _uri, socket) do
    playground = Module.safe_concat([params["playground"]])
    meta = Util.get_metadata(playground)

    socket =
      socket
      |> assign(:playground, playground)
      |> assign(:head, meta[:config][:head] || "")

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <html lang="en">
      <head>
        {{ Phoenix.HTML.Tag.csrf_meta_tag() }}
        <meta charset="utf-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, minimum-scale=1"/>
        {{ raw(@head) }}
      </head>
      <body>
        {{ live_render(@socket, @playground, id: "playground", session: %{"__window_id__" => @__window_id__}) }}
      </body>
    </html>
    """
  end
end
