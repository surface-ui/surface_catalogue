defmodule Surface.Catalogue.ExtendableSort.Adapters.ByCatalogueABC do
  @moduledoc """
  Sort Catalogues in alphabetical order.
  """
  @behaviour Surface.Catalogue.ExtendableSort.Adapter

  @impl true
  def apply(ast) do
    {:ok, sort(ast)}
  end

  @impl true
  def sort(ast) do
    Enum.sort_by(ast, fn p -> p.name end)
  end
end
