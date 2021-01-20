defmodule Surface.Catalogue.Components.Catalogue do
  @behaviour Surface.Catalogue

  @cwd File.cwd!()

  @impl true
  def path() do
    @cwd |> Path.join("catalogue")
  end

  @impl true
  def config() do
    [
      head: """
      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.8.2/css/bulma.min.css" />
      <script defer type="module" src="/js/app.js"></script>
      """
    ]
  end
end
