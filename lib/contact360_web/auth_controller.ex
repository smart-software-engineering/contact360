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
    user = extract_user_info(auth)
    session_user_name = String.to_existing_atom("#{auth.provider}_user")

    conn
    |> login_user_into_auth(auth.provider, user, session_user_name)
    |> redirect(to: "/") # TODO: keep track of the last visited page
  end

  defp extract_user_info(%Ueberauth.Auth{} = auth) do
    IO.inspect(auth: "Bexio Auth Info")

    %{
      firstname: auth.info.first_name,
      lastname: auth.info.last_name,
      email: auth.info.email,
      token: auth.credentials.token,
      token_type: auth.credentials.token_type,
      expires_at: auth.credentials.expires_at,
      refresh_token: auth.credentials.refresh_token,
      scopes: auth.credentials.scopes,
      locale: to_locale(auth.extra.locale)
    }
  end

  defp to_locale("de_CH"), do: :de_CH
  defp to_locale("fr_CH"), do: :fr_CH

  defp login_user_into_auth(conn, :bexio, user, session_user_name) do
    conn
    |> configure_session(renew: true)
    |> put_session(session_user_name, user)
  end
end
