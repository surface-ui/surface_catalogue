defmodule SurfaceCatalogue.SampleComponents.Button.Examples do
  @moduledoc """
  Examples for `<Button>`.
  """

  use Surface.Catalogue.Examples,
    subject: SurfaceCatalogue.SampleComponents.Button,
    catalogue: SurfaceCatalogue.SampleCatalogue,
    height: "90px",
    container: {:div, class: "buttons"}

  @example true
  @doc """
  An example with the default direction `horizontal`.
  """
  def horizontal(assigns) do
    ~F"""
    <Button label="Label" />
    <Button>Slot</Button>
    """
  end

  @example true
  @doc """
  An example with direction `horizontal` with the content larger than the
  code area.
  """
  def horizontal_with_scroll(assigns) do
    ~F"""
    <Button size="normal" color="primary">Normal</Button><Button size="medium" color="warning">Medium</Button>
    """
  end

  @example direction: "vertical", height: "110px"
  @doc "An example with direction `vertical`."
  def vertical(assigns) do
    ~F"""
    <Button>Default</Button>
    <Button size="small" color="info">Small</Button>
    <Button size="normal" color="primary">Normal</Button>
    <Button size="medium" color="warning">Medium</Button>
    <Button size="large" color="danger">Large</Button>
    """
  end
end
