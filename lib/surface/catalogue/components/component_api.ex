defmodule Surface.Catalogue.Components.ComponentAPI do
  use Surface.Component

  alias Surface.Catalogue.Components.Tabs
  alias Surface.Catalogue.Components.Tabs.TabItem
  alias Surface.Catalogue.Components.Table
  alias Surface.Catalogue.Components.Table.Column
  alias Surface.Catalogue.Markdown

  @doc "The component's module"
  prop module, :any, required: true

  data has_api?, :boolean
  data props, :list
  data events, :list
  data slots, :list
  data functions, :list

  def update(assigns, socket) do
    %{
      props: props,
      events: events,
      slots: slots,
      functions: functions
    } = fetch_info(assigns.module)

    has_api? = props != [] || events != [] || slots != [] || functions != []

    socket =
      socket
      |> assign(assigns)
      |> assign(:props, props)
      |> assign(:events, events)
      |> assign(:slots, slots)
      |> assign(:functions, functions)
      |> assign(:has_api?, has_api?)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="ComponentAPI">
      <div :if={{ !@has_api? }}>No public API defined.</div>
      <Tabs id={{ "component-info-tabs-#{@module}" }} :if={{ @has_api? }}>
        <TabItem label="Properties" visible={{ @props != [] }}>
          <Table data={{ prop <- @props }}>
            <Column label="Name">
              <code>{{ prop.name }}</code>
            </Column>
            <Column label="Description">
              {{ format_required(prop) }} {{ prop.doc |> format_desc() |> Markdown.to_html(strip: true) }}
            </Column>
            <Column label="Type">
              <code>{{ inspect(prop.type) }}</code>
            </Column>
            <Column label="Values">
              {{ format_values(prop.opts[:values]) }}
            </Column>
            <Column label="Default">
              {{ format_default(prop.opts) }}
            </Column>
          </Table>
        </TabItem>
        <TabItem label="Slots" visible={{ @slots != [] }}>
          <Table data={{ slot <- @slots }}>
            <Column label="Name">
              <code>{{ slot.name }}</code>
            </Column>
            <Column label="Description">
            {{ format_required(slot) }} {{ slot.doc |> format_desc() |> Markdown.to_html(strip: true) }}
            </Column>
          </Table>
        </TabItem>
        <TabItem label="Events" visible={{ @events != [] }}>
          <Table data={{ event <- @events }}>
            <Column label="Name">
              <code>{{ event.name }}</code>
            </Column>
            <Column label="Description">
              {{ event.doc |> format_desc() |> Markdown.to_html() }}
            </Column>
          </Table>
        </TabItem>
        <TabItem label="Functions" visible={{ @functions != [] }}>
          <Table data={{ func <- @functions }}>
            <Column label="Name">
              <code>{{ func.signature }}</code>
            </Column>
            <Column label="Description">
              {{ func.doc |> format_desc() |> Markdown.to_html() }}
            </Column>
          </Table>
        </TabItem>
      </Tabs>
    </div>
    """
  end

  defp format_required(prop) do
    if prop.opts[:required] do
      {:safe, "<strong>Required</strong>. "}
    else
      ""
    end
  end

  defp format_desc(doc) do
    if doc in [nil, ""] do
      ""
    else
      doc
      |> String.trim()
      |> String.trim_trailing(".")
      |> Kernel.<>(".")
    end
  end

  defp format_values(values) when values in [nil, []] do
    "—"
  end

  defp format_values(values) do
    values
    |> Enum.map(fn value -> raw(["<code>", format_value(value), "</code>"]) end)
    |> Enum.intersperse(", ")
  end

  defp format_value(value) when is_binary(value) do
    value
  end

  defp format_value(value) do
    inspect(value)
  end

  defp format_default(opts) do
    if Keyword.has_key?(opts, :default) do
      raw(["<code>", inspect(opts[:default]), "</code>"])
    else
      "—"
    end
  end

  defp fetch_info(module) do
    functions = fetch_functions(module)

    initial = %{
      props: [],
      events: [],
      slots: module.__slots__(),
      functions: functions
    }

    props = Enum.reverse(module.__props__())

    Enum.reduce(props, initial, fn
      %{type: :event} = prop, acc ->
        %{acc | events: [prop | acc.events]}

      prop, acc ->
        %{acc | props: [prop | acc.props]}
    end)
  end

  defp fetch_functions(module) do
    case Code.fetch_docs(module) do
      {:docs_v1, _line, _beam_language, "text/markdown", _moduledoc, _metadata, docs} ->
        for {{:function, _func, _arity}, _line, [sig | _], %{"en" => doc}, _} <- docs do
          %{signature: sig, doc: doc}
        end

      _ ->
        []
    end
  end
end
