defmodule LiveViewStudioWeb.SandboxLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Sandbox

  import Number.Currency

  def mount(_params, _session, socket) do
    IO.inspect("Snadbox Mount")

    socket =
      assign(socket,
        length: "0",
        width: "0",
        depth: "0",
        weight: 0.0,
        price: nil
      )

    {:ok, socket}
  end

  def handle_event("calculate", params, socket) do
    %{"length" => l, "width" => w, "depth" => d} = params

    weight = Sandbox.calculate_weight(l, w, d)

    socket =
      assign(socket,
        weight: weight,
        length: l,
        width: w,
        depth: d,
        price: nil
      )

    {:noreply, socket}
  end

  def handle_event("get-quote", _params, socket) do
    price = Sandbox.calculate_price(socket.assigns.weight)

    socket = assign(socket, :price, price)

    {:noreply, socket}
  end
end
