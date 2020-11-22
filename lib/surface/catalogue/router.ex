defmodule Surface.Catalogue.Router do
  defmacro surface_catalogue(path, opts \\ []) do
    quote bind_quoted: binding() do
      example_layout = Keyword.get(opts, :example_layout, Surface.Catalogue.LayoutExampleView)

      scope path, alias: false, as: false do
        import Phoenix.LiveView.Router, only: [live: 3]

        alias Surface.Catalogue.{
          LayoutView,
          PageLive,
          ExampleLive,
          PlaygroundLive
        }

        live "/", PageLive, layout: {LayoutView, :root}
        live "/:component/", PageLive, layout: {LayoutView, :root}
        live "/:component/:action", PageLive, layout: {LayoutView, :root}
        live "/:component/example/view", ExampleLive, layout: false
        live "/:component/playground/view", PlaygroundLive, layout: false
      end
    end
  end
end
