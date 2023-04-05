defmodule LiveViewStudio.MyPlug do
  def on_mount(:live_title, _params, _session, socket) do
    IO.inspect("This is My gorgious plug")
    {:cont, socket}
  end
end
