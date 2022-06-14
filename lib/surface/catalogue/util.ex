defmodule Surface.Catalogue.Util do
  @moduledoc false

  def get_components_info do
    for module <- Surface.components(),
        module_loaded?(module),
        reduce: {%{}, %{}} do
      acc ->
        components_reducer(module, module.component_type(), acc)
    end
  end

  def get_examples(component, examples_and_playgrounds) do
    for example <- examples_and_playgrounds[component][:examples] || [],
        meta = Surface.Catalogue.get_metadata(example),
        example_config <- meta.examples_configs do
      config =
        example
        |> Surface.Catalogue.get_config()
        |> Keyword.merge(example_config)

      title = Keyword.get(config, :title)
      func = Keyword.get(config, :func)
      direction = Keyword.get(config, :direction) || "horizontal"
      height = Keyword.get(config, :height) || "120px"
      scrolling = Keyword.get(config, :scrolling) || false
      doc = Keyword.get(config, :doc) || ""
      code = String.trim_trailing(Keyword.get(config, :code) || "")

      {demo_perc, code_perc} =
        case {direction, Keyword.get(config, :code_perc)} do
          {"vertical", _} ->
            {100, 100}

          {"horizontal", nil} ->
            {50, 50}

          {"horizontal", value} ->
            {10 - value, value}
        end

      %{
        module_name: inspect(example),
        func: func,
        doc: doc,
        title: title,
        height: height,
        code: code,
        direction: direction,
        demo_perc: demo_perc,
        code_perc: code_perc,
        scrolling: scrolling
      }
    end
    |> Enum.sort_by(& &1.module_name)
  end

  def get_playgrounds(component, examples_and_playgrounds) do
    for example <- examples_and_playgrounds[component][:playgrounds] || [] do
      inspect(example)
    end
  end

  def split_doc_sections(doc) do
    String.split(doc, [
      "## Examples",
      "## Properties",
      "## Slots",
      "## Events",
      "### Examples",
      "### Properties",
      "### Slots",
      "### Events"
    ])
  end

  defp components_reducer(module, Surface.LiveView, acc) do
    {components, examples_and_playgrounds} = acc

    case Surface.Catalogue.get_metadata(module) do
      %{subject: subject, type: :example} ->
        initial = %{examples: [module], playgrounds: []}

        examples_and_playgrounds =
          Map.update(examples_and_playgrounds, subject, initial, fn info ->
            %{info | examples: [module | info.examples]}
          end)

        {components, examples_and_playgrounds}

      %{subject: subject, type: :playground} ->
        initial = %{examples: [], playgrounds: [module]}

        examples_and_playgrounds =
          Map.update(examples_and_playgrounds, subject, initial, fn info ->
            %{info | playgrounds: [module | info.playgrounds]}
          end)

        {components, examples_and_playgrounds}

      nil ->
        acc
    end
  end

  defp components_reducer(module, _type, {components, examples} = acc) do
    visible_catalogues = Application.get_env(:surface_catalogue, :catalogues)

    docs = Code.fetch_docs(module)

    if match?({:docs_v1, _, _, _, :hidden, _, _}, docs) do
      acc
    else
      module_parts = Module.split(module)

      if !visible_catalogues or Enum.at(module_parts, 0) in visible_catalogues do
        {add_node(module_parts, components), examples}
      else
        acc
      end
    end
  end

  defp add_node([first | rest], parent) do
    node = Map.get(parent, first, %{})
    Map.put(parent, first, add_node(rest, node))
  end

  defp add_node([], parent) do
    parent
  end

  defp module_loaded?(module) do
    match?({:module, _mod}, Code.ensure_compiled(module))
  end
end
