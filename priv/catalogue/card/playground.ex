defmodule SurfaceCatalogue.SampleComponents.Card.Playground do
  use Surface.Catalogue.Playground,
    catalogue: SurfaceCatalogue.SampleCatalogue,
    subject: SurfaceCatalogue.SampleComponents.Card,
    height: "300px"

  @slots [
    default: "DEFAULT",
    header: "HEADER",
    footer: "FOOTER"
  ]
end
