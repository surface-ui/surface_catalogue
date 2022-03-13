# Surface Catalogue

This is mostly a prototype, meant to validate a few ideas to have something similar to
https://storybook.js.org/ for [Surface](https://github.com/msaraiva/surface).

## Installation

Add `surface_catalogue` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:surface_catalogue, "~> 0.3.0"}
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

def catalogues do
  [
    # Local catalogue
    "priv/catalogue",
    # Dependencies catalogues
    "deps/surface/priv/catalogue",
    "deps/surface_bulma/priv/catalogue",
    # External catalogues
    Path.expand("../my_components/priv/catalogue"),
    "/Users/johndoe/workspace/other_components/priv/catalogue"
  ]
end

defp elixirc_paths(:dev), do: ["lib"] ++ catalogues()

...
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

To provide that additional information you must create a module implementing the
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

## Running the built-in catalogue server

In case you're working on a lib that doesn't initialize its own Phoenix endpoint, you
can use the built-in server provided by the `surface_catalogue` following these steps:

Create a `dev.exs` script at the root of your project with the following content:

```elixir
# iex -S mix dev

Logger.configure(level: :debug)

# Start the catalogue server
Surface.Catalogue.Server.start(
  live_reload: [
    patterns: [
      ~r"lib/my_lib_web/live/.*(ex)$"
    ]
  ]
)
```

Make sure you set the `patterns` option according to your project.

To make things easier, add an alias run the script in your `mix.exs`:

```elixir
def project do
  [
    ...,
    aliases: aliases()
  ]
end

...

defp aliases do
  [
    dev: "run --no-halt dev.exs",
    ...
  ]
end
```

Run the server with:

```
mix dev
```

or using `iex`:

```
iex -S mix dev
```

You can now access the catalogue at [localhost:4000](http://localhost:4000/).

If you need, you can also start the server using a different port:

```
PORT=4444 iex -S mix dev
```

## Credits

The `Surface.Catalogue.Server` implementation was mostly extracted from the `dev.exs` script
from [phoenix_live_dashboard](https://github.com/phoenixframework/phoenix_live_dashboard).
All credits to the Phoenix Core Team.

## License

Copyright (c) 2021, Marlus Saraiva.

Surface source code is licensed under the [MIT License](LICENSE.md).
