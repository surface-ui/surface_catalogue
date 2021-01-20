# Surface Catalogue

A **PoC** of something similar to https://storybook.js.org/ for [Surface](https://github.com/msaraiva/surface).

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

That's all!

Run `mix phx.server` and access the "/catalogue" to start playing with your components.

## Contributing

You can run a standalone version of the catalogue with the following commands:

```
mix dev
```

or using `iex`:

```
iex -S mix dev
```

Then you can access the catalogue at [localhost:4444](http://localhost:4444/).

## Credits

The `dev.exs` script was mostly extracted from [phoenix_live_dashboard](https://github.com/phoenixframework/phoenix_live_dashboard).
All credits to the Phoenix Core Team.

## License

Copyright (c) 2021, Marlus Saraiva.

Surface source code is licensed under the [MIT License](LICENSE.md).