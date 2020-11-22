defmodule Surface.Catalogue do
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

  defp get_value_by_key(map, key) when is_map(map) do
    map[key]
  end

  defp get_value_by_key(_map, _key) do
    nil
  end
end
