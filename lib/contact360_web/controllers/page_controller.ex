defmodule Contact360Web.PageController do
  use Contact360Web, :controller

  def home(conn, _params) do
    conn =
      conn
      |> assign(:user, get_session(conn, :user))
      |> assign(:company, get_session(conn, :company_idx))
      |> assign(:version, Application.spec(:contact360, :vsn))

    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def register(conn, _params) do
    render(conn, :register, layout: false)
  end
end
