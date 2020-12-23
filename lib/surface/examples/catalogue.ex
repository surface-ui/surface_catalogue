defmodule Surface.Examples.Catalogue do
  @behaviour Surface.Catalogue

  @impl true
  def config() do
    [
      head: """
      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.8.2/css/bulma.min.css" />
      """
    ]
  end
end
