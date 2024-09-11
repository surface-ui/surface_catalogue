defmodule SurfaceCatalogue.SampleComponents.Button.Playground do
  use Surface.Catalogue.Playground,
    catalogue: SurfaceCatalogue.SampleCatalogue,
    subject: SurfaceCatalogue.SampleComponents.Button,
    height: "170px"

  @slots [
    default: "DEFAULT SLOT"
  ]
end
