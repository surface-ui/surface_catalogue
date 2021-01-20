defmodule Surface.Catalogue.Components.Button.Example03 do
  use Surface.Catalogue.Example,
    catalogue: Surface.Catalogue.Components.Catalogue,
    subject: Surface.Catalogue.Components.Button,
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
