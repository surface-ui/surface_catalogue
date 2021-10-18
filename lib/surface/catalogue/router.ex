defmodule Surface.Catalogue.Router do
  defmacro surface_catalogue(path, opts \\ []) do
    quote bind_quoted: binding() do
      scope path, alias: false, as: false do
        import Phoenix.LiveView.Router

        alias Surface.Catalogue.{
          LayoutView,
          PageLive,
          ExampleLive,
          PlaygroundLive
        }

        live_session :catalogue, root_layout: {LayoutView, :root} do
          live "/", PageLive
          live "/components/:component/", PageLive
          live "/components/:component/:action", PageLive
        end

        live_session :catalogue_playgrounds, root_layout: false do
          live "/examples/:example", ExampleLive
          live "/playgrounds/:playground", PlaygroundLive
        end
      end
    end
  end
end
