defmodule Surface.Catalogue.ExtendableSort do
  def handle(surface_ast) do
    surface_ast
    |> Surface.Catalogue.ExtendableSort.MapHandler.to_extendable_sort()
    |> Surface.Catalogue.ExtendableSort.Builder.from_map()
  end

  def get_sort_config do
    Application.get_env(:surface_catalogue, :sort, [
      Surface.Catalogue.ExtendableSort.Sort.ByCodeDirectory,
      Surface.Catalogue.ExtendableSort.Sort.ByModule,
      Surface.Catalogue.ExtendableSort.Sort.ByTags
    ])
  end
end
