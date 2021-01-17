# SurfaceCatalogue

A **PoC** to validate having something similar to https://storybook.js.org/ for [Surface](https://github.com/msaraiva/surface).

## Installation (development-only usage)

Add `surface_catalogue` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:surface_catalogue, github: "surface-ui/surface_catalogue", only: :dev}
  ]
end
```

Once installed, update your router's configuration:

```elixir
# lib/my_app_web/router.ex
use MyAppWeb, :router
import Surface.Catalogue.Router

...

if Mix.env() == :dev do
  scope "/" do
    pipe_through :browser
    surface_catalogue "/catalogue"
  end
end
```

That's all! Run `mix phx.server` and access the "/catalogue" to start playing with your components.

## License

Copyright (c) 2021, Marlus Saraiva.

Surface source code is licensed under the [MIT License](LICENSE.md).