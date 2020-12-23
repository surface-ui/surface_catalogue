defmodule Surface.Examples.Button.Example_01 do
  use Surface.Example,
    catalogue: Surface.Examples.Catalogue,
    subject: Surface.Examples.Button,
    title: "Label",
    container: {:div, class: "buttons"}

  def render(assigns) do
    ~H"""
    <Button label="Label"/>
    <Button>Slot</Button>
    """
  end
end
