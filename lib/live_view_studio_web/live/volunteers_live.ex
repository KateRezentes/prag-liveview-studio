defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Volunteers.subscribe()
    end

    volunteers = Volunteers.list_volunteers()

    changeset = Volunteers.change_volunteer(%Volunteer{})

    socket =
      socket
      |> stream(:volunteers, volunteers)
      |> assign(:count, 1)
      |> assign(:form, to_form(changeset))

    IO.inspect(socket.assigns.streams.volunteers, label: "mount")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
    
      <.form for={@form} phx-change="validate" phx-submit="save">
        <.input
          field={@form[:name]}
          placeholder="name"
          autocomplete="off"
          phx-debounce="2000"
        />
        <.input
          field={@form[:phone]}
          type="tel"
          placeholder="Phone"
          phx-debounce="blur"
        />
        <.button phx-disable-with="Saving...">
          Check in
        </.button>
      </.form>
      <pre>
      <%!-- <%= inspect(@form, pretty: true) %> --%>
    </pre>
      <div id="volunteers" phx-update="stream">
        <div
          :for={{volunteer_id, volunteer} <- @streams.volunteers}
          class={"volunteer #{if volunteer.checked_out, do: "out"}"}
          id={volunteer_id}
        >
          <div class="name">
            <%= volunteer.name %>
          </div>
          <div class="phone">
            <%= volunteer.phone %>
          </div>
          <div class="status">
            <button phx-click="toggle-status" phx-value-id={volunteer.id}>
              <%= if volunteer.checked_out,
                do: "Check In",
                else: "Check Out" %>
            </button>
            <.link
              class="delete"
              phx-click="delete"
              phx-value-id={volunteer.id}
            >
              <Heroicons.trash />
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, volunteer} = Volunteers.delete_volunteer(volunteer)

    {:noreply, stream_delete(socket, :volunteers, volunteer)}
  end

  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do
    IO.inspect(socket.assigns.streams.volunteers, label: "validate")

    changeset =
      %Volunteer{}
      |> Volunteers.change_volunteer(volunteer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, volunteer} =
      Volunteers.update_volunteer(volunteer, %{checked_out: !volunteer.checked_out})

    {:noreply, stream_insert(socket, :volunteers, volunteer)}
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      {:ok, volunteer} ->
        socket =
          stream_insert(
            socket,
            :volunteers,
            volunteer,
            at: 0
          )

        changeset = Volunteers.change_volunteer(%Volunteer{})

        socket = assign(socket, form: to_form(changeset))

        {:noreply, put_flash(socket, :info, "Volunteer Saved")}
    end
  end

  def handle_info({:volunteer_created, volunteer}, socket) do
    socket = update(socket, :count, &(&1 + 1))
    {:noreply, stream_insert(socket, :volunteers, volunteer, at: 0)}
  end

  def handle_info({:volunteer_updated, volunteer}, socket) do
    socket = update(socket, :count, &(&1 - 1))
    {:noreply, stream_insert(socket, :volunteers, volunteer)}
  end
end
