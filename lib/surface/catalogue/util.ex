defmodule Surface.Catalogue.Util do
  @moduledoc false

  def get_catalogue_config(nil) do
    []
  end

  def get_catalogue_config(catalogue) do
    if module_loaded?(catalogue) do
      catalogue.config()
    else
      []
    end
  end

  def get_metadata(module) do
    case Code.fetch_docs(module) do
      {:docs_v1, _, _, "text/markdown", docs, %{catalogue: meta}, _} ->
        doc = Map.get(docs, "en")
        meta |> Map.new() |> Map.put(:doc, doc)

      _ ->
        nil
    end
  end

  def get_window_id(session, params) do
    key = "__window_id__"

    get_value_by_key(session, key) ||
      get_value_by_key(params, key) ||
      Base.encode16(:crypto.strong_rand_bytes(16))
  end

  def get_components_info do
    for [app] <- loaded_applications(),
        {:ok, modules} = :application.get_key(app, :modules),
        module <- modules,
        module_str = to_string(module),
        String.starts_with?(module_str, "Elixir."),
        module_loaded?(module),
        function_exported?(module, :component_type, 0),
        reduce: {%{}, %{}} do
      acc ->
        components_reducer(module, module.component_type(), acc)
    end
  end

  def get_examples(component, examples_and_playgrounds) do
    for example <- examples_and_playgrounds[component][:examples] || [] do
      meta = get_metadata(example)
      config = meta[:config]
      code = meta |> Map.get(:code, "") |> String.trim_trailing()

      title = Keyword.get(config, :title)
      direction = Keyword.get(config, :direction) || "horizontal"

      {demo_perc, code_perc} =
        case {direction, Keyword.get(config, :code_perc)} do
          {"vertical", _} ->
            {100, 100}

          {"horizontal", nil} ->
            {50, 50}

          {"horizontal", value} ->
            {10 - value, value}
        end

      {inspect(example), title, code, direction, demo_perc, code_perc}
    end |> Enum.sort()
  end

  def get_playgrounds(component, examples_and_playgrounds) do
    examples_and_playgrounds[component][:playgrounds] || []
  end

  defp components_reducer(module, Surface.LiveView, acc) do
    {components, examples_and_playgrounds} = acc

    case get_metadata(module) do
      %{subject: subject, code: _} ->
        initial = %{examples: [module], playgrounds: []}
        examples_and_playgrounds =
          Map.update(examples_and_playgrounds, subject, initial, fn info ->
            %{info | examples: [module | info.examples]}
          end)
        {components, examples_and_playgrounds}

      %{subject: subject} ->
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
    docs = Code.fetch_docs(module)

    if match?({:docs_v1, _, _, _, :hidden, _, _}, docs) do
      acc
    else
      module_parts = Module.split(module)
      {add_node(module_parts, components), examples}
    end
  end

  defp get_value_by_key(map, key) when is_map(map) do
    map[key]
  end

  defp get_value_by_key(_map, _key) do
    nil
  end

  defp add_node([first | rest], parent) do
    node = Map.get(parent, first, %{})
    Map.put(parent, first, add_node(rest, node))
  end

  defp add_node([], parent) do
    parent
  end

  defp loaded_applications do
    # If we invoke :application.loaded_applications/0,
    # it can error if we don't call safe_fixtable before.
    # Since in both cases we are reaching over the
    # application controller internals, we choose to match
    # for performance.
    :ets.match(:ac_tab, {{:loaded, :"$1"}, :_})
  end

  def module_loaded?(module) do
    match?({:module, _mod}, Code.ensure_compiled(module))
  end
end
