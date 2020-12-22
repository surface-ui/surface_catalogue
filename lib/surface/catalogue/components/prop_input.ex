defmodule Surface.Catalogue.Components.PropInput do
  @moduledoc false

  use Surface.Component

  alias Surface.Components.Form.{TextInput, Checkbox, Select, NumberInput}

  prop prop, :any

  prop value, :any

  def render(assigns) do
    ~H"""
    <div class="field is-horizontal">
      <div class="field-label is-small">
        <label class="label">{{ label(@prop) }}</label>
      </div>
      <div class="field-body">
        <div class="field" style="display:flex; align-items:center;">
          <div class="control" style="width: 400px;">
            {{ input(assigns) }}
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp label(prop) do
    required_str = if prop.opts[:required], do: "*", else: ""
    "#{prop.name}#{required_str}"
  end

  defp input(assigns) do
    value = assigns.value || assigns.prop.opts[:default]
    choices = assigns.prop.opts[:values] || []
    prop = assigns.prop

    case {prop.type, choices} do
      {:boolean, _} ->
        ~H"""
        <Checkbox field={{ prop.name }} value={{ value }} opts={{ style: "height: 26px;" }}/>
        """

      {:string, []} ->
        ~H"""
        <TextInput field={{ prop.name }} value={{ value }} class="input is-small" />
        """

      {:string, choices} ->
        ~H"""
        <div class="select is-small">
          <Select field={{ prop.name }} options={{ ["" | choices] }} selected={{ value }}/>
        </div>
        """

      {:list, []} ->
        ~H"""
        <TextInput field={{ prop.name }} value={{ inspect(value) }} class="input is-small" />
        """

      {:integer, []} ->
        ~H"""
        <NumberInput field={{ prop.name }} value={{ value }} class="input is-small" />
        """

      {:integer, choices} ->
        ~H"""
        <div class="select is-small">
          <Select field={{ prop.name }} options={{ ["" | choices] }} selected={{ value }}/>
        </div>
        """

      _ ->
        ~H"""
        TODO
        """
    end
  end
end
