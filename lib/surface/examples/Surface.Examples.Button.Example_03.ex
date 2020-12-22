defmodule Surface.Examples.Button.Example_03 do
  use Surface.Example,
    subject: Surface.Examples.Button,
    title: "Outlined, Rounded and Loading",
    code_perc: 65,
    # TODO: Remove this after moving css files to assets/
    head: """
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.8.2/css/bulma.min.css" />
    """

  def render(assigns) do
    ~H"""
    <div class="buttons">
      <Button color="info" outlined rounded>Outlined</Button>
      <Button color="primary" rounded>Rounded</Button>
      <Button color="danger" rounded loading>Loading</Button>
    </div>
    """
  end
end
