# Used by "mix format"
[
  import_deps: [:phoenix, :surface],
  plugins: [
    Phoenix.LiveView.HTMLFormatter,
    Surface.Formatter.Plugin
  ],
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs,sface}",
    "blend.exs",
    "blend/*.exs",
    "priv/catalogue/**/*.{ex,exs,sface}"
  ]
]
