defmodule Surface.Catalogue.Components.StateDialog do
  @moduledoc false

  use Surface.LiveComponent

  data component_id, :any, default: ""
  data formatted_id, :atom, default: nil
  data formatted_assigns, :string, default: ""
  data show, :boolean, default: false
  data show_builtin, :boolean, default: false
  data show_private, :boolean, default: false
  data playground_pid, :pid, default: nil

  def update(assigns, socket) do
    socket =
      if assigns[:component_id] do
        {formatted_id, formatted_assigns} =
          get_component_formatted_info(
            assigns.playground_pid,
            assigns.component_id,
            show_builtin: socket.assigns.show_builtin,
            show_private: socket.assigns.show_private
          )

        socket
        |> assign(:formatted_id, formatted_id)
        |> assign(:formatted_assigns, formatted_assigns)
      else
        socket
      end

    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ~F"""
    <div class={"modal", "is-active": @show} :on-window-keydown="hide" phx-key="Escape">
      <div class="modal-background" style="background-color: rgba(10,10,10,.30)" />
      <div class="modal-card" style="width: unset; min-width: 600px;">
        <header class="modal-card-head">
          <p class="modal-card-title has-text-grey has-text-weight-medium">
            {@formatted_id}
          </p>
        </header>
        <section class="modal-card-body" style="padding: 0px 1px; background-color: #ddd;">
          <div class="code" style="width: 100%; overflow-y: auto; max-height: 500px;">
            <pre class="makeup-highlight" style="padding: 0rem 1.5rem">
              <code>
    {raw(@formatted_assigns)}</code>
            </pre>
          </div>
        </section>
        <footer class="modal-card-foot" style="padding: 15px 20px;">
          <span style="width: 100%" class="has-text-grey">
            <.form for={%{}} as={:options} phx-change="options_change" phx-target={@myself}>
              <div class="columns is-vcentered" style="margin-top: 0px;">
                <div class="column is-narrow has-text-centered">
                  <div class="control">
                    <label class="checkbox">
                      <input name="options[show_builtin]" type="hidden" value="false">
                      <input
                        id="options_show_builtin"
                        name="options[show_builtin]"
                        type="checkbox"
                        value="true"
                        checked={@show_builtin}
                      />
                      Built-in assigns
                    </label>
                  </div>
                </div>
                <div class="column is-narrow has-text-centered">
                  <div class="control">
                    <label class="checkbox">
                      <input name="options[show_private]" type="hidden" value="false">
                      <input
                        id="options_show_private"
                        name="options[show_private]"
                        type="checkbox"
                        value="true"
                        checked={@show_private}
                      />
                      Private assigns
                    </label>
                  </div>
                </div>
              </div>
            </.form>
          </span>
          <button class="button is-info" :on-click="hide">
            Close
          </button>
        </footer>
      </div>
    </div>
    """
  end

  # Public API

  def show(dialog_id, playground_pid, component_id) do
    send_update(__MODULE__,
      id: dialog_id,
      show: true,
      component_id: component_id,
      playground_pid: playground_pid
    )
  end

  # Event handlers

  def handle_event("hide", _, socket) do
    {:noreply, assign(socket, show: false)}
  end

  def handle_event("options_change", %{"options" => options}, socket) do
    %{"show_builtin" => show_builtin, "show_private" => show_private} = options
    show_builtin = show_builtin == "true"
    show_private = show_private == "true"
    playground_pid = socket.assigns.playground_pid
    component_id = socket.assigns.component_id

    {_formatted_id, formatted_assigns} =
      get_component_formatted_info(
        playground_pid,
        component_id,
        show_builtin: show_builtin,
        show_private: show_private
      )

    socket =
      socket
      |> assign(:show_builtin, show_builtin)
      |> assign(:show_private, show_private)
      |> assign(:formatted_assigns, formatted_assigns)

    {:noreply, socket}
  end

  defp get_component_formatted_info(playground_pid, component_id, opts) do
    show_builtin = Keyword.fetch!(opts, :show_builtin)
    show_private = Keyword.fetch!(opts, :show_private)

    {mod, assigns} = get_component_info(playground_pid, component_id)
    assigns_defs = mod.__data__() ++ mod.__props__()

    assigns =
      for {k, v} <- assigns,
          info = Enum.find(assigns_defs, %{}, &(&1.name == k)),
          show_builtin || info[:doc] != "Built-in assign",
          show_private || info != %{},
          into: %{} do
        {k, v}
      end

    code = inspect(assigns, width: :infinity)
    code_length = String.length(code)
    width = max(25, min(100, code_length - 1))

    formatted_assigns =
      assigns
      |> inspect(pretty: true, width: width)
      |> Makeup.highlight_inner_html()

    formatted_id =
      if component_id == :playground do
        "Playground"
      else
        last_mod = mod |> Module.split() |> List.last()
        "#{last_mod}<\##{component_id}>"
      end

    {formatted_id, formatted_assigns}
  end

  defp get_component_info(playground_pid, :playground) do
    playground_state = :sys.get_state(playground_pid)
    {playground_state.socket.view, playground_state.socket.assigns}
  end

  defp get_component_info(playground_pid, component_id) do
    playground_state = :sys.get_state(playground_pid)
    {components, _, _} = playground_state.components

    {_, {mod, _, data, _, _}} =
      Enum.find(components, &match?({_, {_, ^component_id, _, _, _}}, &1))

    {mod, data}
  end
end
