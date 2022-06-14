defmodule SurfaceCatalogue.SampleComponents.Card do
  @moduledoc """
  A sample Card component.
  """

  use Surface.Component

  @doc """
  The main content
  """
  slot default

  @doc """
  The header content
  """
  slot header

  @doc """
  The footer content
  """
  slot footer

  def render(assigns) do
    ~F"""
    <div class="card">
      <header class="card-header">
        <p class="card-header-title">
          <#slot name="header"/>
        </p>
      </header>
      <div class="card-content">
        <div class="content">
          <#slot>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus nec iaculis mauris.</#slot>
        </div>
      </div>
      <footer class="card-footer">
        <p class="card-footer-item">
          <#slot name="footer"/>
        </p>
      </footer>
    </div>
    """
  end
end
