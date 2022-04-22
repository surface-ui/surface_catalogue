defmodule Surface.Catalogue.ExtendableSort.MapHandler do
  def to_extendable_sort(children, parent \\ "Root", parent_path \\ ["Root"]) do
    for {key, value} <- Enum.sort(children) do
      generated_chain = parent_path ++ [key]
      module = generated_chain |> remove_root |> Module.concat()
      type = module |> component_type

      %{
        name: key,
        children: to_extendable_sort(value, key, generated_chain),
        parent_path: parent_path,
        module: module,
        type: type,
        parent: parent
      }
    end
  end

  defp remove_root(["Root" | rest]), do: rest
  defp remove_root(rest), do: rest

  defp component_type(module) do
    with true <- function_exported?(module, :component_type, 0),
         component_type = module.component_type(),
         true <- component_type != Surface.LiveView do
      component_type
    else
      _ ->
        :none
    end
  end
end
