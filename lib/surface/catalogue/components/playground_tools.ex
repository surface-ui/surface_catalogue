defmodule Surface.Catalogue.Components.PlaygroundTools do
  use Surface.LiveView

  alias Surface.Catalogue.Components.Tabs
  alias Surface.Catalogue.Components.Tabs.TabItem
  alias Surface.Catalogue.Components.PropInput
  alias Surface.Catalogue.Components.StateDialog
  alias Surface.Components.Form
  alias Surface.Catalogue.Playground

  @event_log_tab 2

  @empty_playground_info %{
    pid: "-",
    hibernating?: false,
    total_memory: "-",
    assigns_memory: "-",
    components_memory: "-",
    status: "-",
    components_instances_memory: []
  }

  @playground_info_update_interval 250
  @playground_info_update_interval_native :erlang.convert_time_unit(
                                            @playground_info_update_interval,
                                            :millisecond,
                                            :native
                                          )

  data playground_pid, :pid, default: nil
  data props_values, :map, default: %{}
  data event_log_counter, :integer, default: 1
  data event_log_entries, :list, default: []
  data props, :list, default: []
  data events, :list, default: []
  data has_new_events?, :boolean, default: false
  data selected_tab_index, :integer, default: 0
  data playground_info, :map, default: @empty_playground_info
  data playground_info_timer_ref, :reference, default: nil
  data playground_info_last_updated, :integer, default: nil

  def mount(params, session, socket) do
    if connected?(socket) do
      window_id = Playground.get_window_id(session, params)
      Playground.subscribe(window_id)
    end

    {:ok, socket, temporary_assigns: [event_log_entries: []]}
  end

  def render(assigns) do
    ~H"""
    <div :show={{ @playground_pid != nil }}>
      <Tabs id="playground-tools-tabs" animated=false tab_click_callback={{ &tab_click_callback/1 }}>
        <TabItem label="Properties">
          <div style="margin-top: 0.7rem;">
            <Form for={{ :props_values }} change="change" opts={{ autocomplete: "off" }}>
              <For each={{ prop <- @props }}>
                <PropInput prop={{ prop }} value={{ @props_values[prop.name] }}/>
              </For>
            </Form>
          </div>
        </TabItem>
        <TabItem label="State">
          <div id="playground-tools-state" style="margin-top: 0.7rem;">
            <div class="field is-horizontal">
              <div class="field-label is-small">
                <label class="label">Playground's PID</label>
              </div>
              <div class="field-body">
                <div class="field">
                  {{ @playground_info.pid }}
                </div>
              </div>
            </div>

            <div class="field is-horizontal">
              <div class="field-label is-small">
                <label class="label">Status</label>
              </div>
              <div class="field-body">
                <div class="field">
                  {{ @playground_info.status }}
                  <span :if={{ @playground_info.hibernating? }}>&nbsp;(<a :on-click="wake_up">wake up</a>)</span>
                </div>
              </div>
            </div>

            <div class="field is-horizontal">
              <div class="field-label is-small">
                <label class="label">Total heap memory</label>
              </div>
              <div class="field-body">
                <div class="field">
                  {{ @playground_info.total_memory }}
                  <span :if={{ !@playground_info.hibernating? }}>&nbsp;(<a :on-click="run_gc">run GC</a>)</span>
                </div>
              </div>
            </div>

            <div class="field is-horizontal">
              <div class="field-label is-small">
                <label class="label">Playground's sssigns</label>
              </div>
              <div class="field-body">
                <div class={{ :field, "has-text-grey-light": @playground_info.hibernating? }}>
                  {{ @playground_info.assigns_memory }}
                  <span class="has-text-dark">&nbsp;(<a :on-click="show_playground_state">show</a>)</span>
                </div>
              </div>
            </div>

            <div class="field is-horizontal">
              <div class="field-label is-small">
                <label class="label">Components' assigns</label>
              </div>
              <div class="field-body">
                <div class={{ :field, "has-text-grey-light": @playground_info.hibernating? }}>
                  {{ @playground_info.components_memory }}
                  <span :if={{ @playground_info.components_instances_memory == [] }}>
                    &nbsp;(no stateful child component)
                  </span>
                </div>
              </div>
            </div>
          </div>

          <hr style="margin: 0.7rem 0;">

          <div id="playground-tools-state-instances" style="margin-top: 0.7rem;">
            <div :for={{ {mod, id, value} <- @playground_info.components_instances_memory }} class="field is-horizontal">
              <div class="field-label is-small">
                <label class="label has-text-grey-dark">
                  {{mod}}&lt;<a :on-click="show_component_state" phx-value-component={{id}}>#{{id}}</a>&gt;
                </label>
              </div>
              <div class="field-body">
                <div class={{ :field, "has-text-grey-light": @playground_info.hibernating? }}>
                  {{ value }}
                </div>
              </div>
            </div>
          </div>
        </TabItem>
        <TabItem label="Event Log" visible={{ @events != [] }} changed={{ @has_new_events? }}>
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
        <TabItem label="Debug/Profile">
          <div id="playground-tools-debug-profile-disabled" style="margin-top: 3.0rem; text-align: center;" phx-update="ignore">
            The <strong>window.liveSocket</strong> has not been set. Debug/Profiling is disabled.
          </div>
          <div id="playground-tools-debug-profile" style="margin-top: 0.7rem;" phx-update="ignore">
            <div class="field is-horizontal">
              <div class="field-label is-small">
                <label class="label">Enable debug</label>
              </div>
              <div class="field-body">
                <div class="field" style="display: flex; align-items: center">
                  <div class="control" style="width: 400px">
                    <input
                      id="debug_profile_enable_debug"
                      style="height: 26px;"
                      type="checkbox"
                      onclick="handleEnableDebugClick(this);"
                    >
                  </div>
                </div>
              </div>
            </div>

            <div class="field is-horizontal">
              <div class="field-label is-small">
                <label class="label">Enable latency simulator (ms)</label>
              </div>
              <div class="field-body">
                <div class="field" style="display: flex; align-items: center">
                  <div class="control" style="width: 25px">
                    <input
                      id="debug_profile_enable_latency_sim"
                      style="height: 26px;"
                      type="checkbox"
                      onclick="handleEnableLatencySimClick(this);"
                    >
                  </div>
                  <input
                    id="debug_profile_latency_sim_value"
                    type="number"
                    step="100"
                    class="input is-small"
                    style="width: 80px; margin-right: 5px; text-align: right;"
                    onblur="handleLatencySimValueBlur(this);"
                  >
                </div>
              </div>
            </div>

            <div class="field is-horizontal">
              <div class="field-label is-small">
                <label class="label">Enable profiling</label>
              </div>
              <div class="field-body">
                <div class="field" style="display: flex; align-items: center">
                  <div class="control" style="width: 400px">
                    <input
                      id="debug_profile_enable_profile"
                      style="height: 26px;"
                      type="checkbox"
                      value="true"
                      onclick="handleEnableProfileClick(this);"
                    >
                  </div>
                </div>
              </div>
            </div>
          </div>
        </TabItem>
      </Tabs>
      <StateDialog id="component_state_dialog"/>
    </div>
    """
  end

  def handle_info(
        {:playground_init, playground_pid, subject, props, events, props_values},
        socket
      ) do
    Tabs.set_active_tab("playground-tools-tabs", 0)

    socket =
      socket
      |> assign(playground_pid: playground_pid)
      |> assign(:component_module, subject)
      |> assign(:props, props)
      |> assign(:events, events)
      |> assign(:props_values, props_values)
      |> assign(:has_new_events?, false)
      |> assign(:selected_tab_index, 0)
      |> assign(:playground_info_last_updated, nil)
      |> update_playground_info()
      |> clear_event_log()

    :erlang.trace(playground_pid, true, [:receive])

    send(socket.parent_pid, {:playground_tools_initialized, subject})

    {:noreply, socket}
  end

  def handle_info({:trace, _pid, :receive, {:system, _, _}}, socket) do
    {:noreply, socket}
  end

  def handle_info({:trace, _pid, :receive, _msg}, socket) do
    {:noreply, update_playground_info(socket)}
  end

  def handle_info({:playground_event_received, event, value, props_values}, socket) do
    event_from_subject? = Enum.any?(socket.assigns.events, &("#{&1.name}" == event))

    if event_from_subject? do
      id = :erlang.unique_integer([:positive]) |> to_string()
      time = NaiveDateTime.local_now()

      payload = value |> inspect() |> Code.format_string!() |> to_string()

      message = """
      #{time} - Event <span class="has-text-weight-semibold">"#{event}"</span>, Payload: #{
        payload
      }\
      """

      socket =
        if socket.assigns.selected_tab_index != @event_log_tab do
          assign(socket, :has_new_events?, true)
        else
          socket
        end

      {:noreply, assign(socket, event_log_entries: [{id, message}], props_values: props_values)}
    else
      {:noreply, assign(socket, props_values: props_values)}
    end
  end

  def handle_info(:update_playground_info, socket) do
    {:noreply, assign_playground_info(socket)}
  end

  def handle_info({:tab_clicked, index}, socket) do
    socket =
      if index == @event_log_tab do
        assign(socket, :has_new_events?, false)
      else
        socket
      end

    {:noreply, assign(socket, :selected_tab_index, index)}
  end

  def handle_event("change", %{"props_values" => props_values}, socket) do
    new_props_values =
      convert_props_values(
        props_values,
        socket.assigns.props_values,
        socket.assigns.component_module
      )

    updated_props_values = Map.merge(socket.assigns.props_values, new_props_values)

    if socket.assigns[:playground_pid] do
      send(socket.assigns.playground_pid, {:update_props, updated_props_values})
    end

    {:noreply, assign(socket, :props_values, updated_props_values)}
  end

  def handle_event(
        "text_prop_keydown",
        %{"key" => "Backspace", "prop" => prop, "value" => ""},
        socket
      ) do
    prop_name = String.to_atom(prop)
    prop_info = socket.assigns.component_module.__get_prop__(prop_name)

    if prop_info.opts[:required] do
      {:noreply, socket}
    else
      updated_props_values = Map.put(socket.assigns.props_values, prop_name, nil)
      socket = assign(socket, :props_values, updated_props_values)

      if socket.assigns[:playground_pid] do
        send(socket.assigns.playground_pid, {:update_props, updated_props_values})
      end

      {:noreply, socket}
    end
  end

  def handle_event("text_prop_keydown", _, socket) do
    {:noreply, socket}
  end

  def handle_event("clear_event_log", _, socket) do
    {:noreply, clear_event_log(socket)}
  end

  def handle_event("run_gc", _, socket) do
    :erlang.garbage_collect(socket.assigns.playground_pid)
    {:noreply, update_playground_info(socket)}
  end

  def handle_event("wake_up", _, socket) do
    wakeup_playground(socket.assigns.playground_pid)
    {:noreply, socket}
  end

  def handle_event("show_component_state", %{"component" => component}, socket) do
    wakeup_playground(socket.assigns.playground_pid)
    StateDialog.show("component_state_dialog", socket.assigns.playground_pid, component)
    {:noreply, socket}
  end

  def handle_event("show_playground_state", _, socket) do
    wakeup_playground(socket.assigns.playground_pid)
    StateDialog.show("component_state_dialog", socket.assigns.playground_pid, :playground)
    {:noreply, socket}
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

  defp convert_props_values(props_values, old_values, component) do
    for {k_str, value} <- props_values, into: %{} do
      prop_name = String.to_atom(k_str)
      prop_info = component.__get_prop__(prop_name)

      {prop_name,
       convert_prop_value(prop_info.type, value, old_values[prop_name], prop_info.opts)}
    end
  end

  defp convert_prop_value(_type, "__NIL__", _old_value, _type_opts) do
    nil
  end

  defp convert_prop_value(:boolean, value, _old_value, _type_opts) do
    case value do
      "true" -> true
      "false" -> false
    end
  end

  defp convert_prop_value(:atom, "", _old_value, _type_opts) do
    nil
  end

  defp convert_prop_value(:atom, ":" <> value, _old_value, _type_opts) do
    String.to_atom(value)
  end

  defp convert_prop_value(:atom, value, _old_value, _type_opts) do
    String.to_atom(value)
  end

  defp convert_prop_value(:integer, "", _old_value, _type_opts) do
    nil
  end

  defp convert_prop_value(:integer, value, _old_value, _type_opts) do
    String.to_integer(value)
  end

  defp convert_prop_value(type, "", old_value, _type_opts)
       when type in [:string, :css_class] and old_value in ["", nil] do
    old_value
  end

  defp convert_prop_value(:css_class, value, _old_value, _type_opts) do
    case Surface.TypeHandler.CssClass.expr_to_value([value], []) do
      {:ok, value} -> value
      _ -> ""
    end
  end

  defp convert_prop_value(type, "", old_value, _type_opts)
       when type in [:list, :keyword] and old_value in [[], nil] do
    old_value
  end

  defp convert_prop_value(type, value, _old_value, _type_opts) when type in [:list, :keyword] do
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

  defp convert_prop_value(_type, value, _old_value, _type_opts) do
    value
  end

  defp available_events(events) do
    Enum.map_join(events, " | ", & &1.name)
  end

  defp update_playground_info(socket) do
    socket = cancel_playground_info_udpate(socket)
    time = :erlang.monotonic_time()
    last_updated = socket.assigns.playground_info_last_updated

    if !last_updated || time - last_updated > @playground_info_update_interval_native do
      assign_playground_info(socket)
    else
      timer_ref =
        Process.send_after(self(), :update_playground_info, @playground_info_update_interval)

      assign(socket, :playground_info_timer_ref, timer_ref)
    end
  end

  defp cancel_playground_info_udpate(socket) do
    playground_info_timer_ref = socket.assigns.playground_info_timer_ref

    if playground_info_timer_ref do
      Process.cancel_timer(playground_info_timer_ref)
    end

    assign(socket, :playground_info_timer_ref, nil)
  end

  defp assign_playground_info(socket) do
    playground_pid = socket.assigns.playground_pid

    playground_info =
      if Process.alive?(playground_pid) do
        get_playground_info(playground_pid)
      else
        @empty_playground_info
      end

    socket
    |> assign(:playground_info, playground_info)
    |> assign(:playground_info_last_updated, :erlang.monotonic_time())
  end

  defp get_playground_info(playground_pid) do
    word_size = :erlang.system_info(:wordsize)
    playground_state = :sys.get_state(playground_pid)
    assigns_memory = :erts_debug.size(playground_state.socket.assigns)

    process_info =
      playground_pid
      |> Process.info([:status, :total_heap_size, :current_function])
      |> Map.new()

    hibernating? = match?({:erlang, :hibernate, _}, process_info.current_function)
    status = if hibernating?, do: :hibernating, else: process_info.status

    {components, _, _} = playground_state.components

    {components_instances_memory, components_memory} =
      Enum.reduce(components, {[], 0}, fn
        {_index, {mod, id, data, _, _}}, {instances, total} ->
          last_mod = mod |> Module.split() |> List.last()
          size = :erts_debug.size(data)
          total = total + size
          formatted_size = format_bytes(size * word_size)
          instances = [{last_mod, id, formatted_size} | instances]
          {instances, total}
      end)

    %{
      pid: inspect(playground_pid),
      hibernating?: hibernating?,
      total_memory: format_bytes(process_info.total_heap_size * word_size),
      status: inspect(status),
      assigns_memory: format_bytes(assigns_memory * word_size),
      components_memory: format_bytes(components_memory * word_size),
      components_instances_memory: Enum.reverse(components_instances_memory)
    }
  end

  defp wakeup_playground(playground_pid) do
    send(playground_pid, :wake_up)
  end

  defp format_bytes(bytes) when is_integer(bytes) do
    cond do
      bytes >= memory_unit(:TB) -> format_bytes(bytes, :TB)
      bytes >= memory_unit(:GB) -> format_bytes(bytes, :GB)
      bytes >= memory_unit(:MB) -> format_bytes(bytes, :MB)
      bytes >= memory_unit(:KB) -> format_bytes(bytes, :KB)
      true -> format_bytes(bytes, :B)
    end
  end

  defp format_bytes(bytes, :B) when is_integer(bytes), do: "#{bytes} B"

  defp format_bytes(bytes, unit) when is_integer(bytes) do
    value = bytes / memory_unit(unit)
    "#{:erlang.float_to_binary(value, decimals: 1)} #{unit}"
  end

  defp memory_unit(:TB), do: 1024 * 1024 * 1024 * 1024
  defp memory_unit(:GB), do: 1024 * 1024 * 1024
  defp memory_unit(:MB), do: 1024 * 1024
  defp memory_unit(:KB), do: 1024
end
