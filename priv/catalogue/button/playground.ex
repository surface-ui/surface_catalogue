defmodule SurfaceCatalogue.SampleComponents.Button.Playground do
  use Surface.Catalogue.Playground,
    catalogue: Surface.Components.Catalogue,
    subject: SurfaceCatalogue.SampleComponents.Button,
    height: "170px"

  data props, :map, default: %{}

  def render(assigns) do
    ~F"""
    <Button {...@props}/>
    """
  end
end
