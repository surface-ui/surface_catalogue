defmodule Surface.Catalogue.Components.ComponentInfo do
  @moduledoc false

  use Surface.Component

  alias Surface.Catalogue.Components.ComponentAPI
  alias Surface.Catalogue.Markdown

  @doc "The component module"
  prop module, :module, required: true

  data full_module_name, :string
  data doc_summary, :string
  data doc_details, :string
  data has_details?, :boolean
  data has_docs?, :boolean
  data api_anchor_id, :string

  def update(assigns, socket) do
    prefix = if assigns.module.component_type == Surface.MacroComponent, do: "#", else: ""

    module_name =
      assigns.module
      |> Module.split()
      |> List.last()

    full_module_name = String.replace_prefix(module_name, "", prefix)

    {doc_summary, doc_details} = fetch_doc_details(assigns.module)

    has_summary? = doc_summary not in [nil, ""]
    has_details? = doc_details not in [nil, ""]
    has_docs? = has_summary? or has_details?
    api_anchor_id = "#{module_name}-API"

    socket =
      socket
      |> assign(assigns)
      |> assign(:full_module_name, full_module_name)
      |> assign(:doc_summary, String.trim_trailing(doc_summary || "", "."))
      |> assign(:doc_details, doc_details)
      |> assign(:has_details?, has_details?)
      |> assign(:has_docs?, has_docs?)
      |> assign(:api_anchor_id, api_anchor_id)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="ComponentInfo">
      <h1 class="title">{{ @full_module_name }}</h1>
      {{ Markdown.to_html(@doc_summary, class: "subtitle") }}
      <hr>
      {{ @doc_details |> Markdown.to_html() }}
      <div :if={{ !@has_docs? }}>No documentation available.</div>
      <hr :if={{ !@has_docs? or @has_details? }}>
      <h3 id={{ @api_anchor_id }} class="title is-4 is-spaced">
        <a href={{"##{@api_anchor_id}"}}>#</a> Public API
      </h3>
      <ComponentAPI module={{ @module }}/>
    </div>
    """
  end

  defp fetch_doc_details(module) do
    case Code.fetch_docs(module) do
      {:docs_v1, _, _, "text/markdown", %{"en" => doc}, _, _} ->
        parts =
          String.split(doc, ["## Examples", "### Properties"])
          |> List.first()
          |> String.split("\n\n", parts: 2)

        {Enum.at(parts, 0), Enum.at(parts, 1)}

      _ ->
        {nil, nil}
    end
  end
end
