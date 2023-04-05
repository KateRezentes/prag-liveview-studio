defmodule LiveViewStudioWeb.VehiclesLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Vehicles

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        vehicles: [],
        loading: false,
        suggestions: []
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>🚙 Find a Vehicle 🚘</h1>
    <div id="vehicles">
      <form phx-submit="search" phx-change="suggest">
        <input
          type="text"
          name="query"
          value=""
          placeholder="Make or model"
          autofocus
          autocomplete="off"
          list="suggestions"
        />

        <button>
          <img src="/images/search.svg" />
        </button>
      </form>

      <datalist id="suggestions">
        <option :for={car <- @suggestions} value={car}>
          <%= car %>
        </option>
      </datalist>

      <.loading loading={@loading} />

      <div class="vehicles">
        <ul>
          <li :for={vehicle <- @vehicles}>
            <span class="make-model">
              <%= vehicle.make_model %>
            </span>
            <span class="color">
              <%= vehicle.color %>
            </span>
            <span class={"status #{vehicle.status}"}>
              <%= vehicle.status %>
            </span>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("search", %{"query" => query}, socket) do
    send(self(), {:search, query})

    {:noreply, assign(socket, loading: true, vehicles: [])}
  end

  def handle_event("suggest", %{"query" => query}, socket) do
    suggestions = Vehicles.suggest(query)

    {:noreply, assign(socket, suggestions: suggestions)}
  end

  def handle_info({:search, query}, socket) do
    {:noreply, assign(socket, loading: false, vehicles: Vehicles.search(query))}
  end
end
