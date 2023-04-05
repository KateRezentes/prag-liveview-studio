defmodule LiveViewStudioWeb.PizzaOrdersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.PizzaOrders
  import Number.Currency

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _session, socket) do
    sort_by = params["sort_by"]
    sort_order = params["sort_order"]
    page = params["page"]
    per_page = params["per_page"]

    options = %{
      sort_by: validate_sort_by(sort_by),
      sort_order: sort_validate_order(sort_order),
      page: param_to_integer(page, 1),
      per_page: param_to_integer(per_page, 5)
    }

    {:noreply,
     assign(socket,
       options: options,
       pizza_orders: PizzaOrders.list_pizza_orders(options)
     )}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    params = %{socket.assigns.options | per_page: per_page}
    {:noreply, push_patch(socket, to: ~p"/pizza-orders?#{params}")}
  end

  defp next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end

  defp validate_sort_by(sort_by)
       when sort_by in ~w[size style topping_1 topping_2 price] do
    String.to_existing_atom(sort_by)
  end

  defp validate_sort_by(_param), do: :id

  defp sort_validate_order(sort_order)
       when sort_order in ~w[asc desc] do
    String.to_existing_atom(sort_order)
  end

  defp sort_validate_order(_param), do: :asc

  defp param_to_integer(nil, default), do: default

  defp param_to_integer(param, default) do
    case Integer.parse(param) do
      {number, _} -> number
      :error -> default
    end
  end

  defp is_last_page?(page_number, per_page) do
    page_number * per_page < PizzaOrders.count_pizza_orders()
  end

  defp pages(options) do
    donation_count = PizzaOrders.count_pizza_orders()
    page_count = ceil(donation_count / options.per_page)

    for page_number <- (options.page - 2)..(options.page + 2),
        page_number > 0 do
      if page_number <= page_count do
        current_page? = page_number == options.page
        {page_number, current_page?}
      end
    end
  end
end
