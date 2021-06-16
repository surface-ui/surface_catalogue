defmodule SurfaceCatalogue.SampleComponents.Button.Example02 do
  @moduledoc """
  An example with direction `horizontal` with the content larger than the code
  area.
  """

  use Surface.Catalogue.Example,
    subject: SurfaceCatalogue.SampleComponents.Button,
    catalogue: SurfaceCatalogue.SampleCatalogue,
    title: "Horizontal with scroll",
    height: "90px",
    container: {:div, class: "buttons"}

  def render(assigns) do
    ~F"""
    <Button size="normal" color="primary">Normal</Button><Button size="medium" color="warning">Medium</Button>
    """
  end
end
