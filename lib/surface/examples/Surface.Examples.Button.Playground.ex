defmodule Surface.Examples.Button.Playground do
  use Surface.Playground,
    catalogue: Surface.Examples.Catalogue,
    subject: Surface.Examples.Button,
    style: "height: 60px;"

  data props, :map, default: %{
    label: "My Button",
    color: "success"
  }

  def render(assigns) do
    ~H"""
    <Button :props={{ @props }} />
    """
  end
end
