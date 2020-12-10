defmodule Surface.Catalogue.PageLive do
  use Surface.LiveView

  alias Surface.Catalogue.Components.{ComponentInfo, ComponentTree, PlaygroundTools}
  alias Surface.Components.LivePatch

  data component_name, :string
  data component_module, :module
  data has_example?, :boolean
  data has_playground?, :boolean
  data components, :map
  data action, :string
  data __window_id__, :string

  def mount(params, session, socket) do
    window_id = Surface.Catalogue.get_window_id(session, params)
    socket = assign(socket, :__window_id__, window_id)
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    component_name = params["component"]
    component_module = get_component_by_name(component_name)

    socket =
      socket
      |> assign(:component_name, component_name)
      |> assign(:component_module, component_module)

    socket =
      if component_module do
        # TODO: validate modules
        example_view = Module.concat([component_name, "Example"])
        playground_view = Module.concat([component_name, "Playground"])

        socket
        |> assign(:component_name, component_name)
        |> assign(:component_module, component_module)
        |> assign(:has_example?, module_loaded?(example_view))
        |> assign(:has_playground?, module_loaded?(playground_view))
        |> assign(:action, params["action"] || "docs")
      else
        socket
      end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div style="position: relative;">
      <div class="sidebar-bg"/>
      <div class="container is-fullhd">
        <section class="main-content columns">
          <ComponentTree
            id="component_tree"
            selected_component={{ @component_name }}/>
          <div class="container column" style="background-color: #fff; min-height: 500px;">
            <div :if={{ !@component_module }} class="columns is-centered is-vcentered is-mobile" style="height: 300px">
              <div class="column is-narrow has-text-centered subtitle has-text-grey">
                No component selected
              </div>
            </div>
            <If condition={{ @component_module }}>
              <div class="component tabs is-medium">
                <ul>
                  <li class={{ "is-active": @action == "docs"}}>
                    <LivePatch
                      to={{ @socket.router.__helpers__().live_path(@socket, __MODULE__, @component_name, :docs) }}>
                      <span class="icon is-small"><i class="far fa-file-alt" aria-hidden="true"></i></span>
                      <span>Docs &amp; API</span>
                    </LivePatch>
                  </li>
                  <li :if={{ @has_example? }} class={{ "is-active": @action == "example"}}>
                    <LivePatch
                      to={{ @socket.router.__helpers__().live_path(@socket, __MODULE__, @component_name, :example)}}>
                      <span class="icon is-small"><i class="fas fa-image" aria-hidden="true"></i></span>
                      <span>Example</span>
                    </LivePatch>
                  </li>
                  <li :if={{ @has_playground? }} class={{ "is-active": @action == "playground"}}>
                    <LivePatch
                      to={{ @socket.router.__helpers__().live_path(@socket, __MODULE__, @component_name, :playground)}}>
                      <span class="icon is-small"><i class="far fa-play-circle" aria-hidden="true"></i></span>
                      <span>Playground</span>
                    </LivePatch>
                  </li>
                </ul>
              </div>
              <div class="section">
                <ComponentInfo
                  :if={{ @action == "docs" }}
                  module={{ @component_module }}
                />
                <div id="loading" :if={{ @action in ["example", "playground"] }} class="container">
                  <div class="columns is-centered is-vcentered is-mobile" style="height: 300px">
                    <div class="column is-narrow has-text-centered subtitle has-text-grey">
                      Loading live {{ @action }}...
                    </div>
                  </div>
                </div>
                <iframe
                  :if={{ @action in ["example", "playground"] }}
                  src={{ iframe_src(@socket, @component_name, @action, __window_id__: @__window_id__) }}
                  style="width: 100%; visibility: hidden; overflow-y: scroll;"
                  frameborder="0"
                  onload="onIframeLoaded(this)">
                </iframe>
                <div id="playground_tools_container" style="display: none; padding-top: 1.5rem;">
                  <PlaygroundTools
                    id="playground_tools"
                    :if={{ @action == "playground" }}
                    session={{ %{"component" => @component_name, "__window_id__" => @__window_id__} }}
                  />
                </div>
              </div>
            </If>
          </div>
        </section>
      </div>
    </div>
    """
  end

  defp module_loaded?(module) do
    match?({:module, _mod}, Code.ensure_compiled(module))
  end

  defp get_component_by_name(name) do
    name && Module.safe_concat([name])
  end

  defp iframe_src(socket, component_name, action, params) do
    lv =
      case action do
        "example" -> Surface.Catalogue.ExampleLive
        "playground" -> Surface.Catalogue.PlaygroundLive
      end

    socket.router.__helpers__().live_path(socket, lv, component_name, params)
  end
end
