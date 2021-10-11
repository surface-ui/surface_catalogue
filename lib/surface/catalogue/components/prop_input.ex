defmodule Surface.Catalogue.Components.PropInput do
  @moduledoc false

  use Surface.Component

  alias Surface.Components.Form.{TextInput, Checkbox, Select, NumberInput}

  prop prop, :map

  prop value, :any

  prop form, :form

  def render(assigns) do
    ~F"""
    <div class="field is-horizontal">
      <div class="field-label is-small">
        <label class="label">{label(@prop)}</label>
      </div>
      <div class="field-body">
        <div class="field" style="display:flex; align-items:center;">
          <div class="control" style="width: 400px;">
            {input(assigns)}
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

  defp input(%{prop: prop, value: value, form: form} = assigns) do
    case {prop.type, get_choices(prop)} do
      {:boolean, _} ->
        ~F"""
        <Checkbox field={prop.name} value={value} opts={style: "height: 26px;"} form={form}/>
        """

      {:string, []} ->
        ~F"""
        <TextInput
          field={prop.name}
          value={value}
          class="input is-small"
          opts={placeholder: value == nil && "nil", phx_keydown: "text_prop_keydown", phx_value_prop: prop.name}
         form={form}/>
        """

      {:string, choices} ->
        ~F"""
        <div class="select is-small">
          <Select field={prop.name} options={choices} selected={value} form={form}/>
        </div>
        """

      {:atom, []} ->
        ~F"""
        <TextInput
          field={prop.name}
          value={value_to_string(value)}
          class="input is-small"
          opts={placeholder: value == nil && "nil"}
         form={form}/>
        """

      {:atom, choices} ->
        choices = Enum.map(choices, fn {k, v} -> {inspect(k), inspect(v)} end)

        ~F"""
        <div class="select is-small">
          <Select field={prop.name} options={choices} selected={value_to_string(value)} form={form}/>
        </div>
        """

      {:css_class, _} ->
        ~F"""
        <TextInput
          field={prop.name}
          value={css_value_to_string(value)}
          class="input is-small"
          opts={placeholder: value == nil && "nil", phx_keydown: "text_prop_keydown", phx_value_prop: prop.name}
         form={form}/>
        """

      {:integer, []} ->
        ~F"""
        <NumberInput
          field={prop.name}
          value={value}
          class="input is-small"
          opts={placeholder: value == nil && "nil"}
         form={form}/>
        """

      {:integer, choices} ->
        ~F"""
        <div class="select is-small">
          <Select field={prop.name} options={choices} selected={value} form={form}/>
        </div>
        """

      {type, []} when type in [:list, :keyword] ->
        ~F"""
        <TextInput
          field={prop.name}
          value={value_to_string(value)}
          class="input is-small"
          opts={placeholder: value == nil && "nil", phx_keydown: "text_prop_keydown", phx_value_prop: prop.name}
         form={form}/>
        """

      {type, _} ->
        ~F"""
        <span class="is-size-7">
          [editor not available for type <b>{inspect(type)}</b>]
        </span>
        """
    end
  end

  defp value_to_string(nil), do: nil
  defp value_to_string(value), do: inspect(value)

  defp css_value_to_string(nil), do: nil
  defp css_value_to_string(value), do: Enum.join(value, " ")

  defp get_choices(%{opts: opts}) do
    values = for x <- Keyword.get(opts, :values, []), do: {x, x}

    cond do
      values == [] -> []
      opts[:required] -> values
      true -> [{"nil", "__NIL__"} | values]
    end
  end
end
