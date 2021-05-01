defmodule Surface.Catalogue.Components.ComponentTree do
  @moduledoc false

  use Surface.LiveComponent

  alias Surface.Components.LivePatch

  prop selected_component, :string
  prop single_catalogue?, :boolean
  prop components, :map

  def render(assigns) do
    ~H"""
    <aside
     class="section column is-narrow is-narrow-mobile is-fullheight is-hidden-mobile"
     style="background-color: #f5f5f5; min-width: 270px;"
    >
      {{ render_node(assigns, @components, @selected_component, @single_catalogue?) }}
    </aside>
    """
  end

  def render_node(assigns, node, selected_component, single_catalogue?, parent_keys \\ []) do
    ~H"""
    <ul class={{ "menu-list", "is-hidden": !show_nodes?(parent_keys, selected_component, single_catalogue?) }}>
      <li :if={{ parent_keys == [] }}>
        <LivePatch
          to={{ @socket.router.__helpers__().live_path(@socket, Surface.Catalogue.PageLive) }}
          class={{ "has-text-weight-bold": !selected_component }}
        >
          <span class="icon">
            <i class="fa fa-home" />
          </span>
          Home
        </LivePatch>
      </li>
      <For each={{ {key, value} <- Enum.sort(node),
                    mod_path = parent_keys ++ [key],
                    module = Module.concat(mod_path),
                    component_type = component_type(module),
                    {has_child_selected?} = {has_child_selected?(mod_path, selected_component)} }}>
        <li :if={{ component_type != :none }}>
          <LivePatch
            to={{ @socket.router.__helpers__().live_path(@socket, Surface.Catalogue.PageLive, inspect(module)) }}
            class={{ "has-text-weight-bold": selected_component?(mod_path, selected_component) }}>
            <span class="icon">
              <i class={{ component_icon(component_type) }}></i>
            </span> {{ key }}
          </LivePatch>
        </li>
        <li :if={{ value != %{} && @single_catalogue? && parent_keys == [] }}>
          <a style="cursor: default;">
            <span class="icon">
              <i class="fa fa-puzzle-piece"></i>
            </span> Components
          </a>
          {{ render_node(assigns, value, selected_component, single_catalogue?, mod_path) }}
        </li>
        <li :if={{ value != %{} && (!@single_catalogue? || parent_keys != []) }}>
          <a href="#" onclick="togggleNode(this)">
            <span class="icon">
              <i class={{ :far, "fa-folder-open": has_child_selected?, "fa-folder": !has_child_selected? }}></i>
            </span> {{ key }}
          </a>
          {{ render_node(assigns, value, selected_component, single_catalogue?, mod_path) }}
        </li>
      </For>
    </ul>
    """
  end

  defp component_icon(type) do
    case type do
      Surface.MacroComponent ->
        "fas fa-hashtag"

      _ ->
        "far fa-file-code"
    end
  end

  defp component_type(module) do
    with true <- function_exported?(module, :component_type, 0),
         component_type = module.component_type(),
         true <- component_type != Surface.LiveView do
      component_type
    else
      _ ->
        :none
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
