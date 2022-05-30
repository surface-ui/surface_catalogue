defmodule SurfaceCatalogue.SampleComponents.SampleInputField.Playground do
  use Surface.Catalogue.Playground,
    catalogue: Surface.Components.Catalogue,
    subject: SurfaceCatalogue.SampleComponents.SampleInputField,
    height: "355px"

  data props, :map,
    default: %{
      boolean: true,
      string: "some string",
      string_choices: ["1", "2", "3"],
      atom: :an_atom,
      atom_choices: :a,
      css_class: ["css", "class"],
      integer: 4,
      integer_choices: [1,2,3],
      any: nil,
    }

  def render(assigns) do
    ~F"""
    <SampleInputField {...@props}/>
    """
  end
end
