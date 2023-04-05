defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  on_mount {LiveViewStudio.MyPlug, :live_title}

  def mount(_params, _session, socket) do
    IO.inspect("Lights Mount")
    socket = assign(socket, brightness: 10, temp: "3000", temp_color: temp_color("3000"))
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <form phx-change="temp">
        <div class="temps py-8">
          <%= for temp <- ["3000", "4000", "5000"] do %>
            <div>
              <input
                type="radio"
                id={temp}
                name="temp"
                value={temp}
                checked={temp == @temp}
              />
              <label for={temp}><%= temp %></label>
            </div>
          <% end %>
        </div>
      </form>
      <div class="meter">
        <span style={"width: #{@brightness}%; background: #{temp_color(@temp)}"}>
          <%= @brightness %>%
        </span>
      </div>
      <button phx-click="off">
        <img src="images/light-off.svg" />
      </button>
      <button phx-click="down">
        <img src="images/down.svg" />
      </button>
      <button phx-click="random">
        <img src="images/refresh.svg" />
      </button>
      <button phx-click="up">
        <img src="images/up.svg" />
      </button>
      <button phx-click="on">
        <img src="images/light-on.svg" />
      </button>
      <form>
        <input
          phx-change="shift"
          type="range"
          min="0"
          max="100"
          name="brightness"
          phx-debounce="250"
          value={@brightness}
        />
      </form>
      <.link href={~p"/sandbox"}>Sandbox</.link>
    </div>
    """
  end

  def handle_event("on", _, socket) do
    socket = assign(socket, brightness: 100)
    {:noreply, socket}
  end

  def handle_event("off", _, socket) do
    socket = assign(socket, brightness: 0)
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    socket = update(socket, :brightness, &min(&1 + 10, 100))
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket = update(socket, :brightness, &max(&1 - 10, 0))
    {:noreply, socket}
  end

  def handle_event("random", _, socket) do
    socket = assign(socket, :brightness, Enum.random(1..100))
    {:noreply, socket}
  end

  def handle_event("shift", params, socket) do
    %{"brightness" => brightness} = params
    socket = assign(socket, :brightness, brightness)
    {:noreply, socket}
  end

  def handle_event("temp", params, socket) do
    %{"temp" => temp} = params
    socket = assign(socket, temp: temp, temp_color: temp_color(temp))
    {:noreply, socket}
  end

  defp temp_color("3000"), do: "#F1C40D"
  defp temp_color("4000"), do: "#FEFF66"
  defp temp_color("5000"), do: "#99CCFF"
end
