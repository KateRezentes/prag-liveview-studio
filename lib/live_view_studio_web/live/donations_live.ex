defmodule LiveViewStudioWeb.DonationsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    sort_by = params["sort_by"]
    sort_order = params["sort_order"]
    page = params["page"]
    per_page = params["per_page"]

    options = %{
      sort_by: valid_sort_by(sort_by),
      sort_order: valid_sort_order(sort_order),
      page: param_to_integer(page, 1),
      per_page: param_to_integer(per_page, 5)
    }

    donations = Donations.list_donations(options)

    socket = assign(socket, donations: donations, options: options)

    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    params = %{socket.assigns.options | per_page: per_page}
    {:noreply, push_patch(socket, to: ~p"/donations?#{params}")}
  end

  defp next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end

  attr :options, :map, required: true
  attr :sort_by, :atom, required: true
  slot :inner_block, required: true

  defp sort_link(assigns) do
    params = %{
      assigns.options
      | sort_by: assigns.sort_by,
        sort_order: next_sort_order(assigns.options.sort_order)
    }

    assigns =
      assign(assigns,
        params: params
      )

    ~H"""
    <.link patch={~p"/donations?#{@params}"}>
      <%= render_slot(@inner_block) %> <%= sort_indicator(
        @sort_by,
        @options
      ) %>
    </.link>
    """
  end

  defp sort_indicator(column, %{sort_by: sort_by, sort_order: sort_order})
       when column == sort_by do
    case sort_order do
      :asc -> "👆"
      :desc -> "👇"
    end
  end

  defp sort_indicator(_, _), do: ""

  defp valid_sort_by(sort_by)
       when sort_by in ~w(item quantity days_until_expires) do
    String.to_existing_atom(sort_by)
  end

  defp valid_sort_by(_params), do: :id

  defp valid_sort_order(sort_order)
       when sort_order in ~w(asc desc) do
    String.to_existing_atom(sort_order)
  end

  defp valid_sort_order(_params), do: :asc

  defp param_to_integer(nil, default), do: default

  defp param_to_integer(param, default) do
    case Integer.parse(param) do
      {number, _} -> number
      :error -> default
    end
  end

  defp is_last_page?(page_number, per_page) do
    page_number * per_page < Donations.count_donations()
  end

  defp pages(options) do
    donation_count = Donations.count_donations()
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
