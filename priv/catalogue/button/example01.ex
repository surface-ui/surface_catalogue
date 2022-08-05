defmodule SurfaceCatalogue.SampleComponents.Button.Example01 do
  @moduledoc """
  An example with the default direction `horizontal`.
  """

  use Surface.Catalogue.Example,
    subject: SurfaceCatalogue.SampleComponents.Button,
    catalogue: SurfaceCatalogue.SampleCatalogue,
    title: "Horizontal",
    height: "90px",
    container: {:div, class: "buttons"}

  def render(assigns) do
    ~F"""
    <Button label="Label" />
    <Button>Slot</Button>
    """
  end
end
