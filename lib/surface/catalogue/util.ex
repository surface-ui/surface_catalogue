defmodule Surface.Catalogue.Util do
  @moduledoc false

  def get_components_info do
    for [app] <- loaded_applications(),
        module <- app_modules(app),
        module_loaded?(module),
        function_exported?(module, :component_type, 0),
        reduce: {%{}, %{}} do
      acc ->
        components_reducer(module, module.component_type(), acc)
    end
  end

  def get_examples(component, examples_and_playgrounds) do
    for example <- examples_and_playgrounds[component][:examples] || [] do
      meta = Surface.Catalogue.get_metadata(example)
      config = Surface.Catalogue.get_config(example)
      code = meta |> Map.get(:code, "") |> String.trim_trailing()
      doc =
        meta
        |> Map.get(:doc, "")
        |> String.split("### Properties")
        |> List.first
        |> String.trim()

      title = Keyword.get(config, :title)
      direction = Keyword.get(config, :direction) || "horizontal"
      height = Keyword.get(config, :height) || "120px"

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
        doc: doc,
        title: title,
        height: height,
        code: code,
        direction: direction,
        demo_perc: demo_perc,
        code_perc: code_perc
      }
    end
    |> Enum.sort()
  end

  def get_playgrounds(component, examples_and_playgrounds) do
    for example <- examples_and_playgrounds[component][:playgrounds] || [] do
      inspect(example)
    end
  end

  defp components_reducer(module, Surface.LiveView, acc) do
    {components, examples_and_playgrounds} = acc

    case Surface.Catalogue.get_metadata(module) do
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

  defp module_loaded?(module) do
    match?({:module, _mod}, Code.ensure_compiled(module))
  end

  defp app_modules(app) do
    app
    |> Application.app_dir()
    |> Path.join("ebin/Elixir.*.beam")
    |> Path.wildcard()
    |> Enum.map(&beam_to_module/1)
  end

  defp beam_to_module(path) do
    path |> Path.basename(".beam") |> String.to_atom()
  end
end
