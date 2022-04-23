defmodule Surface.Catalogue.ExtendableSort.Adapters.CategoryFirst do
  @moduledoc """
  Sort Module Maps by Module Name in alphabetical order.
  """
  @behaviour Surface.Catalogue.ExtendableSort.Adapter

  @impl true
  def apply(ast) do
    {:ok, ast |> sort_children |> sort}
  end

  def sort_children([head | tail] = _ast) do
    [sort_children(head) | sort_children(tail)]
  end

  def sort_children(%Surface.Catalogue.ExtendableSort.Category{} = ast) do
    Map.put(
      ast,
      :children,
      ast.children |> sort_children |> sort
    )
  end

  def sort_children(ast) do
    ast
  end

  @impl true
  def sort(ast) do
    Enum.sort_by(ast, fn p -> p.__struct__ end)
  end
end
