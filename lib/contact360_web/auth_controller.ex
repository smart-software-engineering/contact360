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

    conn
    |> login_user_into_auth(auth.provider, user)
    |> redirect(to: "/") # TODO: keep track of the last visited page
  end

  defp extract_user_info(%Ueberauth.Auth{} = auth) do
    %{
      login_id: auth.uid,
      firstname: auth.info.first_name,
      lastname: auth.info.last_name,
      email: auth.info.email,
      token: auth.credentials.token,
      token_type: auth.credentials.token_type,
      expires_at: auth.credentials.expires_at,
      refresh_token: auth.credentials.refresh_token,
      scopes: auth.credentials.scopes,
      locale: to_locale(auth.extra.raw_info.user["locale"]),
      company_id: auth.credentials.other.jwt_payload.company_id
    }
  end

  defp to_locale("de_CH"), do: :de_CH
  defp to_locale("fr_CH"), do: :fr_CH

  defp login_user_into_auth(conn, :bexio, user) do
    company = Contact360.Clients.get_client(user.company_id)
    IO.inspect(user, label: "Bexio Auth Info")
    IO.inspect(company, label: "Company Info")

    if company == nil do
      conn
      |> configure_session(renew: true)
      |> put_flash(:error, "Firma ist noch nicht registriert, bitte erst Firma registrieren!")
      |> put_session(:user, nil)
      |> put_session(:client, nil)
    else
      conn
      |> configure_session(renew: true)
      |> put_session(:user, user)
      |> put_session(:client, user.company_id)
      end

  end
end
