defmodule Surface.Catalogue.Router do
  defmacro surface_catalogue(path, opts \\ []) do
    quote bind_quoted: binding() do
      scope path, alias: false, as: false do
        import Phoenix.LiveView.Router, only: [live: 3]

        alias Surface.Catalogue.{
          LayoutView,
          PageLive,
          ExampleLive,
          PlaygroundLive
        }

        live "/", PageLive, layout: {LayoutView, :root}
        live "/components/:component/", PageLive, layout: {LayoutView, :root}
        live "/components/:component/:action", PageLive, layout: {LayoutView, :root}
        live "/examples/:example", ExampleLive, layout: false
        live "/playgrounds/:playground", PlaygroundLive, layout: false
      end
    end
  end
end
