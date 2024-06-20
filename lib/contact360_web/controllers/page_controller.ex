defmodule Contact360Web.PageController do
  use Contact360Web, :controller

  def home(conn, _params) do
    conn =
      conn
      |> assign(:user, get_session(conn, :user))

    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end
end
