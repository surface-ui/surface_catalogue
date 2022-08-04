defmodule SurfaceCatalogue.SampleComponents.Button.Playground do
  use Surface.Catalogue.Playground,
    catalogue: Surface.Components.Catalogue,
    subject: SurfaceCatalogue.SampleComponents.Button,
    height: "170px"

  @slots [
    default: "DEFAULT SLOT"
  ]
end
