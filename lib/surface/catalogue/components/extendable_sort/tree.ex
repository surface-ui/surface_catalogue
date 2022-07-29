defmodule Surface.Catalogue.Components.ExtendableSort.Tree do
  @moduledoc false

  use Surface.LiveComponent

  alias Surface.Components.LivePatch

  alias Surface.Catalogue.ExtendableSort

  prop selected_component, :string
  prop single_catalogue?, :boolean
  prop components, :any

  def render(assigns) do
    ~F"""
    <div class={"menu-list"}>
      {Surface.Catalogue.Components.ExtendableSort.Item.render(assigns, @components)}
    </div>
    """
  end
end
