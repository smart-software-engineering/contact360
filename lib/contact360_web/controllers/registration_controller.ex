defmodule Contact360Web.RegistrationController do
  use Contact360Web, :controller

  alias Contact360Web.CoreComponents
  alias Contact360.Clients

  def step1(conn, _params) do
    render(conn, :step1, layout: false)
  end

  def step2(conn, _params) do
    user = get_session(conn, :user)
    company = Clients.get_client_by_erp_and_erp_id(:bexio, user.company_id)

    req = bexio_client(user)

    company_profile = BexioApiClient.Others.fetch_company_profiles(req)

    # validate the user and give the feedback
    valid? = valid_user_for_registration?(user)
    company_exists? = company != nil
    company_active? = company != nil and company.active == true

    render(conn, :step2,
      layout: false,
      user: user,
      valid?: valid?,
      company_exists?: company_exists?,
      company_active?: company_active?,
      user: user,
      company: company,
      company_profile: company_profile
    )
  end

  def step3(conn, _params) do
    user = get_session(conn, :user)

    case Clients.register_bexio_client(user) do
      {:ok, client} ->
        conn
        # |> configure_session(drop: true)
        |> render(:step3, layout: false, client: client, errors: nil)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render(:step3,
          layout: false,
          client: nil,
          errors:
            Enum.map(changeset.errors, fn {k, v} -> {k, CoreComponents.translate_error(v)} end)
        )
    end
  end

  defp valid_user_for_registration?(user) do
    case Clients.registering_user_valid(user) do
      :valid ->
        []

      :not_valid ->
        [
          gettext(
            "Es wurde kein Benutzer ausgewählt oder der Benutzer konnte nicht ermittelt werden!"
          )
        ]

      :no_offline_access ->
        [gettext("Dem Benutzer wurde kein Offline-Access gewährt!")]

      :needs_more_scopes ->
        [gettext("Dem Benutzer wurden nicht alle notwendigen Berechtigungen gewährt!")]

      :needs_more_permissions ->
        [gettext("Dem Benutzer fehlen in Bexio Berechtigungen!")]

      _ ->
        false
    end
  end

  defp bexio_client(%{token: token}), do: BexioApiClient.new(token)
end
