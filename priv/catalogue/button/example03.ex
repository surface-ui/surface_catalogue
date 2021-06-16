defmodule SurfaceCatalogue.SampleComponents.Button.Example03 do
  @moduledoc """
  An example with direction `vertical`.
  """

  use Surface.Catalogue.Example,
    subject: SurfaceCatalogue.SampleComponents.Button,
    catalogue: SurfaceCatalogue.SampleCatalogue,
    title: "Vertical",
    direction: "vertical",
    height: "110px",
    container: {:div, class: "buttons"}

  def render(assigns) do
    ~F"""
    <Button>Default</Button>
    <Button size="small" color="info">Small</Button>
    <Button size="normal" color="primary">Normal</Button>
    <Button size="medium" color="warning">Medium</Button>
    <Button size="large" color="danger">Large</Button>
    """
  end
end
