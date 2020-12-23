defmodule Surface.Examples.Button.Example_02 do
  use Surface.Example,
    catalogue: Surface.Examples.Catalogue,
    subject: Surface.Examples.Button,
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
