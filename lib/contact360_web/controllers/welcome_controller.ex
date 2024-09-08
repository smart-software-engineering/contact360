defmodule Contact360Web.WelcomeController do
  use Contact360Web, :controller

  @fake_login_enabled? Application.compile_env(:contact360, :dev_routes)

  def home(conn, _params) do
    conn =
      conn
      |> assign(:version, Application.spec(:contact360, :vsn))
      |> assign(:fake_login_enabled?, @fake_login_enabled?)

    render(conn, :home, layout: false)
  end
end
