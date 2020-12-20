defmodule Surface.Examples.Button.Example do
  use Surface.LiveView

  @moduledoc catalogue: [
    head: """
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.8.2/css/bulma.min.css" />
    """,
    code: File.read!(__ENV__.file)
  ]

  alias Surface.Examples.Button

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
