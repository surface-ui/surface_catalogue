defmodule Surface.Catalogue.ExtendableSort.Adapter do
  @type error :: Exception.t() | String.t()

  @doc """
  Selective filter `children` in a nested data structure and
  apply `sort/1` to them.
  """
  @callback apply(ast :: any) :: {:ok, any} | {:error, error}

  @doc """
  Sorting rules

  ```elixir
  Enum.sort_by(points, fn(p) -> p.points end)
  ```

  ```elixir
  Enum.sort_by(points, fn(p) -> {p.points, p.coordinate} end)
  ```

  https://stackoverflow.com/questions/48310861/sort-list-of-maps-based-on-a-value-within-the-map
  """
  @callback sort(ast :: any) :: {:ok, any} | {:error, error}
end
