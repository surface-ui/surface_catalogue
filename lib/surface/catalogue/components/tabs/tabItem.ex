defmodule Surface.Catalogue.Components.Tabs.TabItem do
  @moduledoc false

  use Surface.Component, slot: "tabs"

  @doc "Item label"
  prop label, :string, default: ""

  @doc "Item icon"
  prop icon, :string

  @doc "Item is disabled"
  prop disabled, :boolean, default: false

  @doc "Item is visible"
  prop visible, :boolean, default: true
end
