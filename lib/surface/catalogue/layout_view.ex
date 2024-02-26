defmodule Surface.Catalogue.LayoutView do
  use Phoenix.Template,
    namespace: Surface.Catalogue,
    root: "lib/surface/catalogue/templates"

  import Surface

  @makeup_css Makeup.stylesheet(Makeup.Styles.HTML.StyleMap.monokai_style(), "makeup-highlight")

  def render("makeup.css", _), do: @makeup_css

  def render(_, assigns) do
    ~F"""
    <html lang="en">
      <head>
        <meta name="csrf-token" content={Phoenix.Controller.get_csrf_token()}>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, minimum-scale=1">
        <title>Component Catalogue</title>
        <link rel="icon" href="data:,">
        <link
          rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css"
        />
        <link phx-track-static rel="stylesheet" href={assets_file("app.css")}>
        {Phoenix.HTML.raw("<style>" <> render("makeup.css", %{}) <> "</style>")}
        <script defer phx-track-static type="text/javascript" src={assets_file("app.js")} />
      </head>
      <body>
        <section class="hero is-info">
          <div class="hero-body" style="padding: 1.5rem">
            <div class="container">
              <h1 class="title">
                <span>{title()}</span>
              </h1>
              <h2 class="subtitle" style="margin-right: 30px">
                {subtitle()}
              </h2>
            </div>
          </div>
        </section>
        {@inner_content}
        <footer class="footer" style="padding: 2rem 1.5rem 2rem; margin-top: 12px;">
          <div class="content has-text-centered">
            <p>
              <strong>Surface</strong> <i>v{surface_version()}</i> -
              <a href="https://github.com/surface-ui/surface">github.com/surface-ui/surface</a>.
            </p>
          </div>
        </footer>
      </body>
    </html>
    """
  end

  defp assets_file(file) do
    path = Application.get_env(:surface_catalogue, :assets_path) || "/assets/catalogue/"
    Path.join(path, file)
  end

  defp surface_version() do
    Application.spec(:surface, :vsn)
  end

  defp title() do
    Application.get_env(:surface_catalogue, :title) || "Surface UI"
  end

  defp subtitle() do
    Application.get_env(:surface_catalogue, :subtitle) || "My Component Catalogue"
  end
end
