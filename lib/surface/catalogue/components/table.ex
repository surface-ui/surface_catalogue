defmodule Surface.Catalogue.Components.Table do
  @moduledoc """
  The inevitable HTML table.

  You can create a table by setting a souce `data` to it and defining
  columns using the `Table.Column` component.
  """

  use Surface.Component

  @doc "The data that populates the table"
  prop data, :list, required: true

  @doc "The table is expanded (full-width)"
  prop expanded, :boolean, default: true

  @doc "Add borders to all the cells"
  prop bordered, :boolean, default: false

  @doc "Add stripes to the table"
  prop striped, :boolean, default: false

  @doc "The CSS class for the wrapping `<div>` element"
  prop class, :css_class

  @doc """
  A function that returns a class for the item's underlying `<tr>`
  element. The function receives the item and index related to
  the row.
  """
  prop rowClass, :fun

  @doc "The columns of the table"
  slot cols, props: [item: ^data], required: true

  def render(assigns) do
    ~H"""
    <div class={{ @class }}>
      <table class={{
        :table,
        "is-fullwidth": @expanded,
        "is-bordered": @bordered,
        "is-striped": @striped
      }}>
        <thead>
          <tr>
            <th :for={{ col <- @cols }}>
              {{ col.label }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            :for={{ {item, index} <- Enum.with_index(@data) }}
            class={{ row_class_fun(@rowClass).(item, index) }}>
            <td :for.index={{ index <- @cols }}>
              <span><slot name="cols" index={{ index }} :props={{ item: item }}/></span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  defp row_class_fun(nil), do: fn _, _ -> "" end
  defp row_class_fun(rowClass), do: rowClass
end
