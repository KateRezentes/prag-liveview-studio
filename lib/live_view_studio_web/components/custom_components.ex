defmodule LiveViewStudioWeb.CustomComponents do
  use Phoenix.Component

  attr :expiration, :integer, default: 24
  slot :legal
  slot :inner_block, required: true

  def promo(assigns) do
    ~H"""
    <div class="promo">
      <div class="deal">
        <%= render_slot(@inner_block) %>
      </div>
      <div class="legal">
        <%= render_slot(@legal) %>
      </div>
      <div class="expiration">
        Deal expires in <%= @expiration %> hours
      </div>
    </div>
    """
  end

  attr :loading, :boolean, required: true

  def loading(assigns) do
    ~H"""
    <div :if={@loading} class="loader">Loading...</div>
    """
  end
end
