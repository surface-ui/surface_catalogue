if Code.ensure_loaded?(Surface.Catalogue.LiveExample) do
  defmodule SurfaceCatalogue.SampleComponents.Button.EventExample do
    @moduledoc """
    An example handling events and manipulating data.
    """

    use Surface.Catalogue.LiveExample,
      subject: SurfaceCatalogue.SampleComponents.Button,
      catalogue: SurfaceCatalogue.SampleCatalogue,
      title: "Handling events and manipulating data",
      height: "90px",
      container: {:div, class: "buttons"},
      assert: "Value: 0"

    data value, :integer, default: 0

    def render(assigns) do
      ~F"""
      <Button click="increment">Value: {@value}</Button>
      """
    end

    def handle_event("increment", _, socket) do
      {:noreply, update(socket, :value, fn value -> value + 1 end)}
    end
  end
end
