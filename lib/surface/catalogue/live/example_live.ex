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
    func = params["func"]
    config = Surface.Catalogue.get_config(example)

    socket =
      socket
      |> assign(:example, example || "")
      |> assign(:head_css, config[:head_css] || "")
      |> assign(:head_js, config[:head_js] || "")
      |> assign(:body, config[:body] || @default_body)
      |> assign(:func, func)

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
        {live_render(@socket, @example, id: "example", session: %{"func" => @func})}
      </body>
    </html>
    """
  end
end
