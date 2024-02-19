defmodule Surface.Catalogue.Components.PropInput do
  @moduledoc false

  use Surface.Component

  alias Surface.Components.Form.{TextInput, Checkbox, Select, NumberInput}

  prop prop, :map

  prop value, :any

  prop form, :form

  prop nil_placeholder, :string, default: "nil"

  data placeholder, :any

  def render(assigns) do
    assigns = assign(assigns, :placeholder, assigns.value == nil && assigns.nil_placeholder)

    ~F"""
    <div class="field is-horizontal">
      <div class="field-label is-small">
        <label class="label">{label(@prop)}</label>
      </div>
      <div class="field-body">
        <div class="field" style="display:flex; align-items:center;">
          <div class="control" style="width: 400px;">
            <.input prop={@prop} value={@value} form={@form} placeholder={@placeholder} />
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
    case {assigns.prop.type, get_choices(assigns.prop)} do
      {:boolean, _} ->
        ~F"""
        <Checkbox field={@prop.name} value={@value} opts={style: "height: 26px;"} form={@form} />

        {error_message(@prop)}
        """

      {:string, []} ->
        ~F"""
        <TextInput
          field={@prop.name}
          value={@value}
          class="input is-small"
          opts={placeholder: @placeholder, phx_keydown: "text_prop_keydown", phx_value_prop: @prop.name}
          form={@form}
        />

        {error_message(@prop)}
        """

      {:string, choices} ->
        assigns = assign(assigns, choices: choices)

        ~F"""
        <div class="select is-small">
          <Select field={@prop.name} options={@choices} selected={@value} form={@form} />
        </div>

        {error_message(@prop)}
        """

      {:atom, []} ->
        ~F"""
        <TextInput
          field={@prop.name}
          value={value_to_string(@value)}
          class="input is-small"
          opts={placeholder: @placeholder}
          form={@form}
        />

        {error_message(@prop)}
        """

      {:atom, choices} ->
        choices = Enum.map(choices, fn {k, v} -> {inspect(k), inspect(v)} end)
        assigns = assign(assigns, choices: choices)

        ~F"""
        <div class="select is-small">
          <Select field={@prop.name} options={@choices} selected={value_to_string(@value)} form={@form} />
        </div>

        {error_message(@prop)}
        """

      {:css_class, _} ->
        ~F"""
        <TextInput
          field={@prop.name}
          value={css_value_to_string(@value)}
          class="input is-small"
          opts={placeholder: @placeholder, phx_keydown: "text_prop_keydown", phx_value_prop: @prop.name}
          form={@form}
        />

        {error_message(@prop)}
        """

      {:number, []} ->
        ~F"""
        <NumberInput
          field={@prop.name}
          value={@value}
          class="input is-small"
          opts={placeholder: @placeholder}
          form={@form}
        />

        {error_message(@prop)}
        """

      {:integer, []} ->
        ~F"""
        <NumberInput
          field={@prop.name}
          value={@value}
          class="input is-small"
          opts={placeholder: @placeholder}
          form={@form}
        />

        {error_message(@prop)}
        """

      {:integer, choices} ->
        assigns = assign(assigns, choices: choices)

        ~F"""
        <div class="select is-small">
          <Select field={@prop.name} options={@choices} selected={@value} form={@form} />
        </div>

        {error_message(@prop)}
        """

      {type, []} when type in [:list, :keyword] ->
        ~F"""
        <TextInput
          field={@prop.name}
          value={value_to_string(@value)}
          class="input is-small"
          opts={placeholder: @placeholder, phx_keydown: "text_prop_keydown", phx_value_prop: @prop.name}
          form={@form}
        />

        {error_message(@prop)}
        """

      {_type, _} ->
        ~F"""
        <span class="is-size-7">
          [editor not available for type <b>{inspect(@prop.type)}</b>]
        </span>
        """
    end
  end

  defp value_to_string(nil), do: nil
  defp value_to_string(value), do: inspect(value)

  defp css_value_to_string(nil), do: nil
  defp css_value_to_string(value), do: Enum.join(value, " ")

  defp get_choices(prop) do
    values = Keyword.get(prop.opts, :values, []) ++ Keyword.get(prop.opts, :values!, [])
    values = Enum.map(values, &{&1, &1})

    cond do
      values == [] -> []
      prop.opts[:required] -> values
      true -> [{"nil", "__NIL__"} | values]
    end
  end

  defp error_message(%{error: _} = assigns) do
    ~F"""
    <p class="help is-danger">Value must be a {@type}</p>
    """
  end

  defp error_message(assigns) do
    ~F"""
    """
  end
end
