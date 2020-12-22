defmodule Surface.Catalogue.Components.Table.Column do
  @moduledoc false

  use Surface.Component, slot: "cols"

  @doc "Column header text"
  prop label, :string, required: true
end
