defmodule Surface.Examples.Button.Playground do
  use Surface.Playground,
    subject: Surface.Examples.Button,
    style: "height: 60px;",
    # TODO: Remove this after moving css files to assets/
    head: """
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.8.2/css/bulma.min.css" />
    """

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
