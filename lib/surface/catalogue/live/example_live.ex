defmodule Surface.Catalogue.ExampleLive do
  use Surface.LiveView

  @default_body [style: "padding: 1.5rem; height: 100%;"]

  data example, :module
  data head_css, :string
  data head_js, :string
  data body, :keyword
  data code, :string

  def handle_params(params, _uri, socket) do
    example = Module.safe_concat([params["example"]])
    config = Surface.Catalogue.get_config(example)

    socket =
      socket
      |> assign(:example, example || "")
      |> assign(:head_css, config[:head_css] || "")
      |> assign(:head_js, config[:head_js] || "")
      |> assign(:body, config[:body] || @default_body)

    {:noreply, socket}
  end

  def render(assigns) do
    ~F"""
    <html lang="en">
      <head>
        {Phoenix.HTML.Tag.csrf_meta_tag()}
        <meta charset="utf-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, minimum-scale=1"/>
        {raw(@head_css)}
        {raw(@head_js)}
      </head>
      <body :attrs={@body}>
        {live_render(@socket, @example, id: "example")}
      </body>
    </html>
    """
  end
end
