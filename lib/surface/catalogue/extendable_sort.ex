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

  def run_extendable(ast, module) do
    case apply(module, :apply, [ast]) do
      {:ok, returned_ast} ->
        {:ok, returned_ast}

      {:error, _message} ->
        {:error, ast}

      _ ->
        {:error, ast}
    end
  end

  def apply_sort_list(init_ast, [head | tail] = _sort_modules) do
    {_resp_type, ast} = run_extendable(init_ast, head)
    apply_sort_list(ast, tail)
  end

  def apply_sort_list(ast, [] = _sort_modules) do
    ast
  end
end
