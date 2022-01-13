defmodule Surface.Catalogue.LayoutView do
  use Phoenix.View,
    namespace: Surface.Catalogue,
    root: "lib/surface/catalogue/templates"

  import Surface

  js_path = Path.join(__DIR__, "../../../priv/static/assets/app.js")
  css_path = Path.join(__DIR__, "../../../priv/static/assets/app.css")

  @external_resource js_path
  @external_resource css_path

  @app_js if File.exists?(js_path), do: File.read!(js_path), else: ""
  @app_css if File.exists?(css_path), do: File.read!(css_path), else: ""
  @makeup_css Makeup.stylesheet(Makeup.Styles.HTML.StyleMap.monokai_style(), "makeup-highlight")

  def render("app.js", _), do: @app_js
  def render("app.css", _), do: @app_css
  def render("makeup.css", _), do: @makeup_css

  def render(_, assigns) do
    ~F"""
    <html lang="en">
      <head>
        {Phoenix.HTML.Tag.csrf_meta_tag()}
        <meta charset="utf-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, minimum-scale=1"/>
        <title>Component Catalogue</title>
        <link rel="icon" href="data:,">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css" />
        {Phoenix.HTML.raw("<style>" <> render("app.css") <> "</style>")}
        {Phoenix.HTML.raw("<style>" <> render("makeup.css") <> "</style>")}
        {Phoenix.HTML.raw("<script>" <> render("app.js") <> "</script>")}
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
              <a href="http://github.com/msaraiva/surface">github.com/msaraiva/surface</a>.
            </p>
          </div>
        </footer>
      </body>
    </html>
    """
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
