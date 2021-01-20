defmodule Surface.Catalogue.Components.Button.Example01 do
  use Surface.Catalogue.Example,
    catalogue: Surface.Catalogue.Components.Catalogue,
    subject: Surface.Catalogue.Components.Button,
    title: "Label",
    container: {:div, class: "buttons"}

  def render(assigns) do
    ~H"""
    <Button label="Label"/>
    <Button>Slot</Button>
    """
  end
end
