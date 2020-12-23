defmodule Surface.Examples.Button.Example_03 do
  use Surface.Example,
    catalogue: Surface.Examples.Catalogue,
    subject: Surface.Examples.Button,
    title: "Outlined, Rounded and Loading",
    code_perc: 65,
    container: {:div, class: "buttons"}

  def render(assigns) do
    ~H"""
    <Button color="info" outlined rounded>Outlined</Button>
    <Button color="primary" rounded>Rounded</Button>
    <Button color="danger" rounded loading>Loading</Button>
    """
  end
end
