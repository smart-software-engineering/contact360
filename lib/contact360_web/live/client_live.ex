defmodule Contact360Web.ClientLive do
  use Contact360Web, :live_view

  def mount(params, session, socket) do
    IO.inspect({params, session, socket}, label: "Params, Session, Socket")

    {:ok, socket |> assign(:params, params) |> assign(:session, session)}
  end

  def render(assigns) do
    ~H"""
    <.header>Startseite</.header>
    <div>
      <div class="code"><%= inspect(assigns) %></div>
    </div>
    """
  end
end
