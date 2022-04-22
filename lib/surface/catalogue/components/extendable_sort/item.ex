defmodule Surface.Catalogue.Components.ExtendableSort.Item do
  @moduledoc false

  use Surface.LiveComponent

  alias Surface.Catalogue.ExtendableSort
  alias Surface.Components.LivePatch

  prop selected_component, :string
  prop single_catalogue?, :boolean
  prop components, :map

  def render(assigns, node) when is_list(node) do
    ~F"""
      {#for item <- node}
        {#if item.__struct__ == Surface.Catalogue.ExtendableSort.Category}
          <ul>
            {render(assigns, item)}
          </ul>
        {#else}
          {render(assigns, item)}
        {/if}
      {#else}
        <div></div>
      {/for}
    """
  end

  def render(assigns, %ExtendableSort.Category{name: "Root"} = node) do
    ~F"""
    <ul class={""}>
      {render(assigns, node.children)}
    </ul>
    """
  end

  def render(assigns, %ExtendableSort.Category{} = node) do
    ~F"""
    <li>
      <a href="#" onclick="toggleNode(this)">
        <span class="icon">
          <i class={:far, "fa-folder-open"}></i>
        </span>
        {node.name}
      </a>
      <ul>
        {render(assigns, node.children)}
      </ul>
    </li>
    """
  end

  def render(assigns, %ExtendableSort.Module{} = node) do
    ~F"""
    <li>
      <LivePatch
        to={@socket.router.__helpers__().live_path(@socket, Surface.Catalogue.PageLive, inspect(node.module))}>
        <span class="icon">
          <i class={"far fa-file-code"}></i>
        </span> {node.name}
      </LivePatch>
    </li>
    """
  end

  #
  # Private
  #

  defp component_icon(type) do
    case type do
      Surface.MacroComponent ->
        "fas fa-hashtag"

      _ ->
        "far fa-file-code"
    end
  end

  defp selected_component?(mod_path, component) do
    component == Enum.join(mod_path, ".")
  end

  defp has_child_selected?(_mod_path, nil) do
    false
  end

  defp has_child_selected?(mod_path, component) do
    String.starts_with?(component, Enum.join(mod_path, ".") <> ".")
  end

  defp show_nodes?(_parent_keys = [], _selected_component, _single_catalogue?) do
    true
  end

  defp show_nodes?(parent_keys, selected_component, single_catalogue?) do
    has_child_selected?(parent_keys, selected_component) or
      (single_catalogue? and length(parent_keys) == 1)
  end
end
