defmodule Surface.Catalogue.ExampleLive do
  use Surface.LiveView

  data example_view, :module
  data title, :string
  data head, :string
  data code, :string

  def handle_params(params, _uri, socket) do
    # TODO: validate example view
    example_view = Module.safe_concat([params["component"], "Example"])
    meta = Surface.Catalogue.get_metadata(example_view)

    socket =
      socket
      |> assign(:example_view, example_view || "")
      |> assign(:head, meta[:head] || "")
      |> assign(:title, meta[:title] || "Example")
      |> assign(:code, meta[:code])

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <html lang="en">
      <head>
        {{ Phoenix.HTML.Tag.csrf_meta_tag() }}
        <meta charset="utf-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, minimum-scale=1">
        {{ raw(@head) }}
        <script defer type="module" src="/js/app.js"></script>
      </head>
      <body>
        {{ live_render(@socket, @example_view, id: "example") }}
      </body>
    </html>
    """
  end
end
