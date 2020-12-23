defmodule Surface.Catalogue.ExampleLive do
  use Surface.LiveView

  alias Surface.Catalogue.Util

  data example_view, :module
  data head, :string
  data style, :string
  data class, :string
  data code, :string

  def handle_params(params, _uri, socket) do
    example_view = Module.safe_concat([params["example"]])
    meta = Util.get_metadata(example_view)

    socket =
      socket
      |> assign(:example_view, example_view || "")
      |> assign(:head, meta[:head] || "")
      |> assign(:style, meta[:style] || "")
      |> assign(:class, meta[:class])

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <html lang="en" id="myhtml_example">
      <head>
        {{ Phoenix.HTML.Tag.csrf_meta_tag() }}
        <meta charset="utf-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, minimum-scale=1"/>
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
