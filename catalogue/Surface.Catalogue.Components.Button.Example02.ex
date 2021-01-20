defmodule Surface.Catalogue.Components.Button.Example02 do
  use Surface.Catalogue.Example,
    catalogue: Surface.Catalogue.Components.Catalogue,
    subject: Surface.Catalogue.Components.Button,
    title: "Colors & Sizes",
    direction: "vertical",
    container: {:div, class: "buttons"}

  def render(assigns) do
    ~H"""
    <Button>Default</Button>
    <Button size="small" color="info">Small</Button>
    <Button size="normal" color="primary">Normal</Button>
    <Button size="medium" color="warning">Medium</Button>
    <Button size="large" color="danger">Large</Button>
    """
  end
end
