defmodule SurfaceCatalogue.SampleComponents.EditableProps.Playground do
  use Surface.Catalogue.Playground,
    catalogue: Surface.Components.Catalogue,
    subject: SurfaceCatalogue.SampleComponents.EditableProps,
    height: "355px"

  @props [
    boolean: true,
    string: "some string",
    string_choices: "2",
    atom: :an_atom,
    atom_choices: :a,
    css_class: ["css", "class"],
    integer: 4,
    integer_choices: 2,
    number: 3.14,
    list: [1, "string", :atom],
    keyword: [key1: 1, key2: "2", key3: :three],
    any: %{a: :map}
  ]
end
