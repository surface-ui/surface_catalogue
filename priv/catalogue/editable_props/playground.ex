defmodule SurfaceCatalogue.SampleComponents.EditableProps.Playground do
  use Surface.Catalogue.Playground,
    catalogue: Surface.Components.Catalogue,
    subject: SurfaceCatalogue.SampleComponents.EditableProps,
    height: "355px"

  @props [
    boolean: true,
    string: "some string",
    string_choices: ["1", "2", "3"],
    atom: :an_atom,
    atom_choices: :a,
    css_class: ["css", "class"],
    integer: 4,
    integer_choices: [1, 2, 3],
    any: nil
  ]
end
