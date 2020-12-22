defmodule Surface.Examples.Button.Example_01 do
  use Surface.Example,
    subject: Surface.Examples.Button,
    # TODO: Remove this after moving css files to assets/
    head: """
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.8.2/css/bulma.min.css" />
    """

  def render(assigns) do
    ~H"""
    <Button>My Button</Button>
    """
  end
end
