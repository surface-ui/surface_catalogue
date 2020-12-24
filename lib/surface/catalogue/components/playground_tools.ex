defmodule Surface.Catalogue.Components.PlaygroundTools do
  use Surface.LiveView

  alias Surface.Catalogue.Components.Tabs
  alias Surface.Catalogue.Components.Tabs.TabItem
  alias Surface.Catalogue.Components.PropInput
  alias Surface.Components.Form

  data playground_pid, :any, default: nil
  data props_values, :map, default: %{}
  data event_log_counter, :integer, default: 1
  data event_log_entries, :list, default: []
  data props, :list, default: []
  data events, :list, default: []
  data has_new_events?, :boolean, default: false
  data selected_tab_index, :integer, default: 0

  def mount(params, session, socket) do
    if connected?(socket) do
      window_id = Surface.Catalogue.Util.get_window_id(session, params)
      Phoenix.PubSub.subscribe(Surface.Catalogue.PubSub, "Surface.Catalogue:#{window_id}")
    end

    {:ok, socket, temporary_assigns: [event_log_entries: []]}
  end

  def render(assigns) do
    ~H"""
    <div :show={{ @playground_pid != nil }}>
      <Tabs id="tools-tabs" animated=false tab_click_callback={{ &tab_click_callback/1 }}>
        <TabItem label="Properties">
          <div style="margin-top: 0.7rem;">
            <Form for={{ :props_values }} change="change" opts={{ autocomplete: "off" }}>
              <For each={{ prop <- @props }}>
                <PropInput prop={{ prop }} value={{ @props_values[prop.name] }}/>
              </For>
            </Form>
          </div>
        </TabItem>
        <TabItem label="Event Log {{ @has_new_events? && "*" || "" }}" visible={{ @events != [] }}>
          <span style="margin-left: 1.0rem;">
            <span class="has-text-weight-semibold">Events: </span>
            <span>{{ available_events(@events) }}</span>
            <span style="float: right; padding-right: 1.0rem;">
              <a :on-click="clear_event_log">Clear</a>
            </span>
          </span>
          <hr style="margin: 0.8rem 0;">
          <div id="event-log" style="height: 250px; overflow: scroll; font-family: monospace" class="is-size-7">
            <div id="event-log-content-{{ @event_log_counter }}" phx-update="append" phx-hook="EventLog">
              <p :for={{ {id, message} <- @event_log_entries }} id="event-log-message-{{ id }}">
                <span style="white-space: break-spaces;">{{ raw(message) }}</span>
              </p>
            </div>
          </div>
        </TabItem>
      </Tabs>
    </div>
    """
  end

  def handle_info({:playground_init, playground_pid, subject, props, events, props_values}, socket) do
    Tabs.set_active_tab("tools-tabs", 0)

    socket =
      socket
      |> assign(playground_pid: playground_pid)
      |> assign(:component_module, subject)
      |> assign(:props, props)
      |> assign(:events, events)
      |> assign(:props_values, props_values)
      |> assign(:has_new_events?, false)
      |> assign(:selected_tab_index, 0)
      |> clear_event_log()

    {:noreply, socket}
  end

  def handle_info({:playground_event_received, event, value, props_values}, socket) do
    id = :erlang.unique_integer([:positive]) |> to_string()
    time = NaiveDateTime.local_now()

    payload = value |> inspect() |> Code.format_string!() |> to_string()
    message = """
    #{time} - Event <span class="has-text-weight-semibold">"#{event}"</span>, Payload: #{payload}\
    """

    socket =
      if socket.assigns.selected_tab_index != 1 do
        assign(socket, :has_new_events?, true)
      else
        socket
      end

    {:noreply, assign(socket, event_log_entries: [{id, message}], props_values: props_values)}
  end

  def handle_info({:tab_clicked, index}, socket) do
    socket =
      if index == 1 do
        assign(socket, :has_new_events?, false)
      else
        socket
      end

    {:noreply, assign(socket, :selected_tab_index, index)}
  end

  def handle_event("change", %{"props_values" => props_values}, socket) do
    new_props_values = convert_props_values(props_values, socket.assigns.component_module)
    updated_props_values = Map.merge(socket.assigns.props_values, new_props_values)

    if socket.assigns[:playground_pid] do
      send(socket.assigns.playground_pid, {:update_props, updated_props_values})
    end

    {:noreply, assign(socket, :props_values, updated_props_values)}
  end

  def handle_event("clear_event_log", _, socket) do
    {:noreply, clear_event_log(socket)}
  end

  def handle_event(event, value, socket) do
    IO.inspect("Event #{event} received. Value: #{inspect(value)}")
    {:noreply, socket}
  end

  def tab_click_callback(index) do
    send(self(), {:tab_clicked, index})
  end

  def clear_event_log(socket) do
    update(socket, :event_log_counter, &(&1 + 1))
  end

  defp convert_props_values(props_values, component) do
    for {k_str, value} <- props_values, into: %{} do
      prop_name = String.to_atom(k_str)
      prop_info = component.__get_prop__(prop_name)
      {prop_name, convert_prop_value(prop_info.type, value)}
    end
  end

  defp convert_prop_value(:boolean, value) do
    case value do
      "true" -> true
      "false" -> false
    end
  end

  defp convert_prop_value(:integer, value) do
    String.to_integer(value)
  end

  defp convert_prop_value(:list, value) do
    try do
      case Code.eval_string(value) do
        {val, _} when is_list(val) -> val
        _ -> []
      end
    rescue
      e ->
        IO.inspect(e)
        []
    end
  end

  defp convert_prop_value(_type, value) do
    value
  end

  defp available_events(events) do
    Enum.map_join(events, " | ", & &1.name)
  end
end
