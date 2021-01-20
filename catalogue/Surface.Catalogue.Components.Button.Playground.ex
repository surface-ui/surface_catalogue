defmodule Surface.Catalogue.Components.Button.Playground do
  use Surface.Catalogue.Playground,
    catalogue: Surface.Catalogue.Components.Catalogue,
    subject: Surface.Catalogue.Components.Button,
    container: {:div, style: "height: 60px;"}

  data props, :map,
    default: %{
      label: "My Button",
      color: "success"
    }

  def render(assigns) do
    ~H"""
    <Button :props={{ @props }} />
    """
  end
end
