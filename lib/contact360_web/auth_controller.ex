defmodule Contact360Web.AuthController do
  use Contact360Web, :controller

  plug Ueberauth

  alias Contact360Web.BexioFaker
  alias Ueberauth.Strategy.Helpers
  import Phoenix.Component

  require Logger

  def request(conn, %{"provider" => "faker"} = params) do
    IO.inspect(conn.params, label: "Conn Param")
    IO.inspect(params, label: "Param")

    render(conn, "request.html",
      callback_url: Helpers.callback_url(conn),
      company_form: to_form(%{"company_id" => BexioFaker.client_id(), "registration" => false})
    )
  end

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, gettext("Sie wurden abgemeldet!"))
    |> configure_session(dropped: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: fails}} = conn, _params) do
    conn
    |> put_flash(:error, gettext("Konnte nicht angemeldet werden:") <> " #{inspect(fails)}")
    |> redirect(to: "/")
  end

  def callback(conn, %{"company_id" => company_id, "provider" => "faker"}) do
    user = %{
      login_id: "faker-123",
      firstname: "Max",
      lastname: "Muster",
      email: "max.muster@smart.nowhere",
      token: "faker-token",
      token_type: "Bearer",
      expires_at: 3600,
      refresh_token: "refresh-123",
      scopes: ["openid", "profile", "email", "offline_access"],
      locale: :de_CH,
      company_id: company_id
    }

    conn
    |> put_session(:user, user)
    |> redirect(to: "/register/step2")

    #      _company ->
    #        conn
    #        |> put_session(:user, user)
    #        |> put_session(:client, user.company_id)
    #        |> redirect(to: "/c/#{user.company_id}")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user = extract_user_info(auth)
    company = Contact360.Clients.get_client_by_erp_and_erp_id(:bexio, user.company_id)

    cond do
      Enum.member?(user.scopes, "offline_access") ->
        Logger.info(
          "Benutzer hat sich angemeldet mit offline-access für die Registrierung der Firma"
        )

        conn
        |> put_session(:user, user)
        |> redirect(to: "/register/step2")

      company == nil ->
        conn
        |> configure_session(renew: true)
        |> put_flash(
          :error,
          gettext("Firma ist noch nicht registriert, bitte Firma zuerst registrieren.")
        )
        |> put_session(:user, nil)
        |> put_session(:client, nil)
        |> redirect(to: "/register/step1")

      true ->
        conn
        |> configure_session(renew: true)
        |> put_session(:user, user)
        |> put_session(:client, user.company_id)
        |> redirect(to: "/c/#{user.company_id}")
    end
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
end
