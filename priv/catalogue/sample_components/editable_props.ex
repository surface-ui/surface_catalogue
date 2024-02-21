defmodule SurfaceCatalogue.SampleComponents.EditableProps do
  @moduledoc """
  A sample component that defines props of all types that can be edited in the Playground.
  """
  use Surface.Component

  prop boolean, :boolean
  prop string, :string
  prop string_choices, :string, values: ["1", "2", "3"]
  prop atom, :atom
  prop atom_choices, :atom, values: [:a, :b, :c]
  prop css_class, :css_class
  prop integer, :integer
  prop integer_choices, :integer, values: [1, 2, 3]
  prop number, :number
  prop list, :list
  prop keyword, :keyword
  prop any, :any

  def render(assigns) do
    ~F"""
    <h1>Input Fields Available in Playground:</h1>
    <br>
    <p><strong>boolean</strong>: {@boolean}</p>
    <p><strong>string</strong>: {@string}</p>
    <p><strong>string_choices</strong>: {@string_choices}</p>
    <p><strong>atom</strong>: {inspect(@atom)}</p>
    <p><strong>atom_choices</strong>: {inspect(@atom_choices)}</p>
    <p><strong>css_class</strong>: {inspect(@css_class)}</p>
    <p><strong>integer</strong>: {@integer}</p>
    <p><strong>integer_choices</strong>: {@integer_choices}</p>
    <p><strong>number</strong>: {@number}</p>
    <p><strong>list</strong>: {inspect(@list)}</p>
    <p><strong>keyword</strong>: {inspect(@keyword)}</p>
    <p><strong>any</strong>: {inspect(@any)}</p>
    """
  end
end
