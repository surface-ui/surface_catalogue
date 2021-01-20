defmodule Surface.Catalogue.Components.Button do
  @moduledoc """
  The classic **button**, in different colors, sizes, and states
  """

  use Surface.Component

  @doc "The label of the button, when no content (default slot) is provided"
  prop label, :string

  @doc "The color of the button"
  prop color, :string, values: ~w(white black light dark primary link info success warning danger)

  @doc "The vertical size of button"
  prop size, :string, values: ~w(small normal medium large)

  @doc "The value for the button"
  prop value, :string

  @doc "Button is expanded (full-width)"
  prop expand, :boolean

  @doc "Set the button as disabled preventing the user from interacting with the control"
  prop disabled, :boolean

  @doc "Outlined style"
  prop outlined, :boolean

  @doc "Rounded style"
  prop rounded, :boolean

  @doc "Hovered style"
  prop hovered, :boolean

  @doc "Focused style"
  prop focused, :boolean

  @doc "Active style"
  prop active, :boolean

  @doc "Selected style"
  prop selected, :boolean

  @doc "Loading state"
  prop loading, :boolean

  @doc "Triggered on click"
  prop click, :event

  @doc """
  The content of the generated `<button>` element. If no content is provided,
  the value of property `label` is used instead.
  """
  slot default

  def render(assigns) do
    ~H"""
    <button
      type="button"
      :on-click={{@click}}
      disabled={{@disabled}}
      value={{@value}}
      class={{
        "button",
        "is-#{@color}": @color,
        "is-#{@size}": @size,
        "is-fullwidth": @expand,
        "is-outlined": @outlined,
        "is-rounded": @rounded,
        "is-hovered": @hovered,
        "is-focused": @focused,
        "is-active": @active,
        "is-loading": @loading,
        "is-selected": @selected
      }}>
      <slot>{{ @label }}</slot>
    </button>
    """
  end
end
