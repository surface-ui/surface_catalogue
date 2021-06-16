defmodule SurfaceCatalogue.SampleCatalogue do
  @moduledoc """
  Sample catalogue.
  """

  use Surface.Catalogue

  load_asset "assets/bulma.min.css", as: :bulma_css

  @impl true
  def config() do
    [
      head_css: """
      <style>#{@bulma_css}</style>
      """,
      playground: [
        body: [
          style: "padding: 1.5rem; height: 100%;",
          class: "has-background-light"
        ]
      ]
    ]
  end
end
