defmodule Surface.Examples.Button.Example_02 do
  use Surface.Example,
    subject: Surface.Examples.Button,
    title: "Colors & Sizes",
    direction: "vertical",
    # TODO: Remove this after moving css files to assets/
    head: """
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.8.2/css/bulma.min.css" />
    """

  def render(assigns) do
    ~H"""
    <div class="buttons">
      <Button>Default</Button>
      <Button size="small" color="info">Small</Button>
      <Button size="normal" color="primary">Normal</Button>
      <Button size="medium" color="warning">Medium</Button>
      <Button size="large" color="danger">Large</Button>
    </div>
    """
  end
end
