defmodule Surface.Catalogue.LayoutView do
  use Phoenix.View,
    namespace: Surface.Catalogue,
    root: "lib/surface/catalogue/templates"

  import Surface

  def render(_, assigns) do
    ~H"""
    <html lang="en">
      <head>
        {{ Phoenix.HTML.Tag.csrf_meta_tag() }}
        <meta charset="utf-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, minimum-scale=1">
        <title>Component Catalogue</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.8.2/css/bulma.min.css" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/3.7.2/animate.min.css" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css" />
        <style>
          .menu-list li ul {
            margin-top: .2em;
            margin-bottom: .3em;
          }

          .menu-list li a {
            padding: .4em .75em;
          }

          .animated.faster {
            animation-duration: 0.3s;
          }

          .section {
            padding-top: 1.5rem;
          }

          .sidebar-bg {
            position: absolute;
            bottom: 0;
            right: 50%;
            left: 0;
            top: 0;
            background: #f5f5f5;
            z-index: -1;
          }

          .main-content {
            margin-top: 0px;
            margin-bottom: 0px;
            position: relative;
          }

          .component.tabs {
            margin-bottom: 0.5rem;
          }

          .component.tabs li.is-active a {
            border-bottom-width: 2px;
          }

          #playground_tools .tabs {
            margin-bottom: 0.8rem;
          }

          @media screen and (min-width: 769px) {
            .main-content > div.container {
              min-width: 500px;
            }
          }

          .markdown {
            margin-top: 2em;
          }

          /* Components.ComponentInfo */

          .ComponentInfo .subtitle {
            color: #7a7a7a;
          }

          /* Components.ComponentAPI */

          .ComponentAPI table{
            font-size: .9rem;
          }

          .ComponentAPI .table td, .table th {
            line-height: 1.5;
          }
        </style>

        <script>
          function togggleNode(a) {
            a.parentNode.querySelector('.menu-list').classList.toggle('is-hidden')
            i = a.querySelector('span.icon > i')
            i.classList.toggle('fa-folder-open')
            i.classList.toggle('fa-folder')
          }

          function onExampleLoaded(iframe) {
            iframe.style.height = "0px";
            iframe.style.height = iframe.contentWindow.document.documentElement.scrollHeight + 'px'
            iframe.style.visibility = "visible"
            document.getElementById("loading").style.display = "none"
            playground_tools_container = document.getElementById("playground_tools_container")
            if (playground_tools_container) {
              playground_tools_container.style.display = "block"
            }
          }
        </script>

        <script defer type="module" src="/js/app.js"></script>
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
