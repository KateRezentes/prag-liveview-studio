defmodule LiveViewStudioWeb.BoatsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Boats
  alias LiveViewStudioWeb.CustomComponents

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [boats: []]}
  end

  def handle_params(params, _uri, socket) do
    filter = %{type: params["type"] || "", prices: params["prices"] || [""]}
    boats = Boats.list_boats(filter)

    {:noreply, assign(socket, boats: boats, filter: filter)}
  end

  def render(assigns) do
    ~H"""
    <h1>Daily Boat Rentals</h1>
    <CustomComponents.promo expiration={2}>
      Save 25% off today
      <:legal>
        <Heroicons.exclamation_circle /> Limit one per party
      </:legal>
    </CustomComponents.promo>
    <div id="boats">
      <.filters filter={@filter} />
      <div class="boats">
        <.boats :for={boat <- @boats} boat={boat} />
      </div>
      <CustomComponents.promo expiration={1}>
        Hurry! Only 3 boats left!
        <:legal>
          Exluding Weekends
        </:legal>
      </CustomComponents.promo>
    </div>
    """
  end

  def filters(assigns) do
    ~H"""
    <form phx-change="filter">
      <div class="filters">
        <select name="type">
          <%= Phoenix.HTML.Form.options_for_select(
            type_options(),
            @filter.type
          ) %>
        </select>
        <div class="prices">
          <%= for price <- ["$", "$$", "$$$"] do %>
            <input
              type="checkbox"
              name="prices[]"
              value={price}
              id={price}
              checked={price in @filter.prices}
            />
            <label for={price}><%= price %></label>
          <% end %>
          <input type="hidden" name="prices[]" value="" />
        </div>
      </div>
    </form>
    """
  end

  attr :boat, LiveViewStudio.Boats.Boat, required: true

  def boats(assigns) do
    ~H"""
    <div class="boat">
      <img src={@boat.image} />
      <div class="content">
        <div class="model">
          <%= @boat.model %>
        </div>
        <div class="details">
          <span class="price">
            <%= @boat.price %>
          </span>
          <span class="type">
            <%= @boat.type %>
          </span>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("filter", %{"prices" => prices, "type" => type}, socket) do
    filter = %{type: type, prices: prices}
    {:noreply, push_patch(socket, to: ~p"/boats?#{filter}")}
  end

  defp type_options do
    [
      "All Types": "",
      Fishing: "fishing",
      Sporting: "sporting",
      Sailing: "sailing"
    ]
  end
end
