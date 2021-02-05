defmodule Surface.Catalogue.LayoutView do
  use Phoenix.View,
    namespace: Surface.Catalogue,
    root: "lib/surface/catalogue/templates"

  import Surface

  js_path = Path.join(__DIR__, "../../../priv/static/js/app.js")
  css_path = Path.join(__DIR__, "../../../priv/static/css/app.css")

  @external_resource js_path
  @external_resource css_path

  @app_js File.read!(js_path)
  @app_css File.read!(css_path)
  @makeup_css Makeup.stylesheet(Makeup.Styles.HTML.StyleMap.monokai_style, "makeup-highlight")

  def render("app.js", _), do: @app_js
  def render("app.css", _), do: @app_css
  def render("makeup.css", _), do: @makeup_css

  def render(_, assigns) do
    ~H"""
    <html lang="en">
      <head>
        {{ Phoenix.HTML.Tag.csrf_meta_tag() }}
        <meta charset="utf-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, minimum-scale=1"/>
        <title>Component Catalogue</title>
        <link rel="icon" href="data:,">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css" />
        <style>{{ Phoenix.HTML.raw(render("app.css")) }}</style>
        <style>{{ Phoenix.HTML.raw(render("makeup.css")) }}</style>
        <script>{{ Phoenix.HTML.raw(render("app.js")) }}</script>
      </head>
      <body>
        <section class="hero is-info">
          <div class="hero-body" style="padding: 1.5rem">
            <div class="container">
              <h1 class="title">
                <span>Surface UI</span>
              </h1>
              <h2 class="subtitle" style="margin-right: 30px">
              My Component Catalogue
              </h2>
            </div>
          </div>
        </section>
        {{ @inner_content }}
        <footer class="footer" style="padding: 2rem 1.5rem 2rem; margin-top: 12px;">
          <div class="content has-text-centered">
            <p>
              <strong>Surface</strong> <i>v{{ surface_version() }}</i> -
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
end
