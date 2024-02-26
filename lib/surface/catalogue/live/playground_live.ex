defmodule Surface.Catalogue.PlaygroundLive do
  use Surface.LiveView

  alias Surface.Catalogue.Playground

  @default_body [style: "padding: 1.5rem; height: 100%; background-color: #f5f5f5"]

  data playground, :module
  data head_css, :string
  data head_js, :string
  data body, :keyword
  data __window_id__, :string

  def mount(params, session, socket) do
    window_id = Playground.get_window_id(session, params)
    socket = assign(socket, :__window_id__, window_id)
    {:ok, socket, temporary_assigns: [event_log_entries: []]}
  end

  def handle_params(params, _uri, socket) do
    playground = Module.safe_concat([params["playground"]])
    config = Surface.Catalogue.get_config(playground)

    socket =
      socket
      |> assign(:playground, playground)
      |> assign(:head_css, config[:head_css] || "")
      |> assign(:head_js, config[:head_js] || "")
      |> assign(:body, config[:body] || @default_body)

    {:noreply, socket}
  end

  def render(assigns) do
    ~F"""
    <html lang="en">
      <head>
        <meta name="csrf-token" content={Phoenix.Controller.get_csrf_token()}>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, minimum-scale=1">
        {raw(@head_css)}
        {raw(@head_js)}
      </head>
      <body {...@body}>
        {live_render(@socket, @playground, id: "playground", session: %{"__window_id__" => @__window_id__})}
      </body>
    </html>
    """
  end
end
