defmodule Surface.Catalogue.Components.ComponentTree do
  @moduledoc false

  use Surface.LiveComponent

  alias Surface.Components.LivePatch

  prop selected_component, :string

  prop components, :map

  def render(assigns) do
    ~H"""
    <aside
     class="section column is-narrow is-narrow-mobile is-fullheight is-hidden-mobile"
     style="background-color: #f5f5f5; min-width: 270px;"
    >
      {{ render_node(assigns, @components, @selected_component) }}
    </aside>
    """
  end

  def render_node(assigns, node, selected_component, parent_keys \\ []) do
    ~H"""
    <ul class={{ "menu-list", "is-hidden": parent_keys != [] and !has_child_selected?(parent_keys, selected_component) }}>
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
        <li :if={{ value != %{} }}>
          <a href="#" onclick="togggleNode(this)">
            <span class="icon">
              <i class={{ :far, "fa-folder-open": has_child_selected?, "fa-folder": !has_child_selected? }}></i>
            </span> {{ key }}
          </a>
          {{ render_node(assigns, value, selected_component, mod_path) }}
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
end
