defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Servers.subscribe()
    end

    servers = Servers.list_servers()

    socket =
      assign(socket,
        servers: servers,
        coffees: 0
      )

    {:ok, socket}
  end

  def handle_params(_params, _uri, %{assigns: %{live_action: :new}} = socket) do
    changeset = Server.changeset(%Server{}, %{})

    {:noreply,
     assign(socket,
       selected_server: nil,
       page_title: "New Server",
       form: to_form(changeset)
     )}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    server = Servers.get_server!(id)

    {:noreply,
     assign(socket,
       selected_server: server,
       page_title: server.name
     )}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply,
     assign(socket,
       selected_server: hd(socket.assigns.servers)
     )}
  end

  def render(assigns) do
    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <.link patch={~p"/servers/new"} class="add">+ Add Server</.link>
          <.link
            :for={server <- @servers}
            patch={~p"/servers/#{server}"}
            class={if server == @selected_server, do: "selected"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link>
        </div>
        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div>
      </div>
      <div class="main">
        <div class="wrapper">
          <div class="server">
            <%= if @live_action == :new do %>
              <.form for={@form} phx-change="validate" phx-submit="save">
                <.input
                  field={@form[:name]}
                  placeholder="name"
                  autocomplete="off"
                  phx-debounce="blur"
                />
                <.input
                  field={@form[:framework]}
                  placeholder="framework"
                  phx-debounce="blur"
                />
                <.input
                  field={@form[:size]}
                  placeholder="size"
                  phx-debounce="blur"
                />
                <.input
                  field={@form[:status]}
                  placeholder="status"
                  phx-debounce="blur"
                />
                <.input
                  field={@form[:deploy_count]}
                  placeholder="deploy_count"
                  phx-debounce="blur"
                />
                <.input
                  field={@form[:last_commit_message]}
                  placeholder="last_commit_message"
                  phx-debounce="2000"
                />
                <.button phx-disable-with="Saving...">
                  Save
                </.button>
                <.link patch={~p"/servers"} class="cancel">
                  Cancel
                </.link>
              </.form>
            <% else %>
              <div class="header">
                <h2><%= @selected_server.name %></h2>
                <button
                  phx-click="change-status"
                  class={@selected_server.status}
                >
                  <%= @selected_server.status %>
                </button>
              </div>
              <div class="body">
                <div class="row">
                  <span>
                    <%= @selected_server.deploy_count %> deploys
                  </span>
                  <span>
                    <%= @selected_server.size %> MB
                  </span>
                  <span>
                    <%= @selected_server.framework %>
                  </span>
                </div>
                <h3>Last Commit Message:</h3>
                <blockquote>
                  <%= @selected_server.last_commit_message %>
                </blockquote>
              </div>
            <% end %>
          </div>
          <div class="links">
            <.link navigate={~p"/light"}>
              Adjust Lights
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("drink", _, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_event("change-status", _, socket) do
    server = socket.assigns.selected_server

    Servers.update_server(server, %{status: change_status(server.status)})

    {:noreply, socket}
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      {:ok, server} ->
        changeset = Servers.change_server(%Server{})

        socket =
          socket
          |> assign(form: to_form(changeset))
          |> put_flash(:info, "Server")
          |> push_patch(to: ~p"/servers/#{server.id}")

        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"server" => server_params}, socket) do
    changeset =
      %Server{}
      |> Server.changeset(server_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_info({:server_updated, server}, socket) do
    servers =
      Enum.map(socket.assigns.servers, fn s ->
        if s.id == server.id, do: server, else: s
      end)

    socket =
      if socket.assigns.selected_server && socket.assigns.selected_server.id == server.id do
        assign(socket, servers: servers, selected_server: server)
      else
        assign(socket, servers: servers)
      end

    {:noreply, socket}
  end

  def handle_info({:server_created, server}, socket) do
    socket =
      update(
        socket,
        :servers,
        fn servers -> [server | servers] end
      )

    {:noreply, socket}
  end

  defp change_status("down"), do: "up"
  defp change_status("up"), do: "down"
end
