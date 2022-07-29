defmodule Surface.Catalogue.ExtendableSort.Builder do
  alias Surface.Catalogue.ExtendableSort

  def from_map(children) when is_list(children) do
    Enum.map(children, fn x -> map_inspector(x) end) |> List.flatten()
  end

  def from_map(module) do
    map_inspector(module)
  end

  def map_inspector(map) do
    case {is_module?(map), has_children?(map)} do
      # not module, has children
      {false, true} ->
        [cast_to_category(map)]

      # is module, has children
      {true, true} ->
        [cast_to_module(map), cast_to_category(map)]

      # is module, no children
      {true, false} ->
        [cast_to_module(map)]

      # everything else would be pointless to include
      {_, _} ->
        []
    end
  end

  defp cast_to_category(map) do
    {_, new_map} =
      map
      # categories don't have modules
      |> Map.drop([:module])
      |> Map.get_and_update!(:children, fn current_value ->
        {current_value, from_map(current_value)}
      end)

    struct(ExtendableSort.Category, new_map)
  end

  defp cast_to_module(map) do
    # modules don't have children
    new_map = map |> Map.drop([:children])
    struct(ExtendableSort.Module, new_map)
  end

  defp is_module?(%{type: type}) when type != :none, do: true
  defp is_module?(_), do: false

  defp has_children?(%{children: [_head | _tail]}), do: true
  defp has_children?(_), do: false
end
