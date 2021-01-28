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

Update your `router.ex` configuration:

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

Run `mix phx.server` and access "/catalogue" to see the list of all available components in
your project.

## Loading Examples and Playgrounds

If you want to access examples and playgrounds for components, edit your `mix.exs` file,
adding a new entry for `elixirc_paths` along with a `catalogues` function listing the
catalogues you want to be loaded:

```elixir
...

defp elixirc_paths(:dev), do: ["lib"] ++ catalogues()

...

defp catalogues do
  [
    # Local catalogue
    "priv/catalogue",
    # Dependencies catalogues
    "deps/surface/priv/catalogue",
    "deps/surface_bulma/priv/catalogue",
    # External catalogues
    Path.expand("../my_componensts/priv/catalogue"),
    "/Users/johndoe/workspace/other_componensts/priv/catalogue"
  ]
end
```

Then update the endpoint configuration in `config/dev.exs` to set up live reloading
for your catalogue:

```elixir
config :my_app, MyAppWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/catalogue/.*(ex)$",
      ...
    ]
  ]
```

> **Note**: Without the above configurations, the list of available components is
> still presented in the catalogue page. However, when selecting a component, only
> its documentation and API will be shown. No example/playground will be loaded nor
> tracked by Phoenix's live reloader.

## Sharing catalogues

If you're working on a suite of components that you want to share as a library, you
may need to provide additional information about the catalogue. This will be necessary
whenever your components require any `css` or `js` code that might not be available
on the host project.

To provide that addicional information you must create a module inplementing the
`Surface.Catalogue` behaviour in your `priv/catalogue/` folder. Example:

```elixir
defmodule MySuite.Catalogue do
  use Surface.Catalogue

  @impl true
  def config() do
    [
      head_css: """
      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.8.2/css/bulma.min.css" />
      """
    ]
  end
end
```


## Running the catalogue from `surface_catalogue`

You can run a standalone version of the catalogue by running the following command
inside the `surface_catalogue` project:

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