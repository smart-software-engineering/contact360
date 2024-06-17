defmodule Contact360Web.AuthController do
  use Contact360Web, :controller

  plug Ueberauth

  alias Ueberauth.Strategy.Helpers

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> clear_session()
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate: #{inspect(fails)}")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    IO.inspect(auth, label: "Auth Response")
    user = extract_user_info(auth)
    token_name = String.to_existing_atom("#{auth.provider}_user")

    conn
    |> put_flash(:info, "Successfully authenticated with #{auth.provider}.")
    |> put_session(token_name, user)
    |> configure_session(renew: true)
    |> redirect(to: "/")
  end

  defp extract_user_info(%Ueberauth.Auth{} = auth) do
    %{
      firstname: auth.info.first_name,
      lastname: auth.info.last_name,
      email: auth.info.email,
      token: auth.credentials.token,
      token_type: auth.credentials.token_type,
      expires_at: auth.credentials.expires_at
    }
  end
end
