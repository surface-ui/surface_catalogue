defmodule Surface.Catalogue.Components.Tabs.TabItem do
  @moduledoc """
  Defines a tab item for the parent tabs component.

  The tab item instance is automatically added to the
  parent's `tabs` slot.
  """

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
