defmodule Contact360Web.WelcomeController do
  use Contact360Web, :controller

  def home(conn, _params) do
    conn =      assign(conn, :version, Application.spec(:contact360, :vsn))

    render(conn, :home, layout: false)
  end
end
