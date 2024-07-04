defmodule Contact360.Clients.BexioRegistration do
  @moduledoc """
  Handles the client registration process for Bexio.
  """
  alias Contact360.Clients.Client
  alias Contact360.Repo
  alias Contact360.Scheduler.BexioStaticDataFetcher

  @needed_scopes [
    "kb_invoice_show",
    "openid",
    "offline_access",
    "contact_show",
    "note_show",
    "kb_offer_show",
    "kb_order_show"
  ]

  @doc """
  Creates a client.

  ## Examples

      iex> register_client(%{field: value})
      {:ok, %Client{}}

      iex> register_client(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def register_bexio_client(user) do
    user
    |> registering_user_valid?()
    |> do_register_bexio_client(user)
  end

  defp do_register_bexio_client(:valid, user) do
    existing_client = Repo.get_by(Client, cloud_erp: :bexio, erp_id: user.company_id)

    case BexioStaticDataFetcher.fetch_company_profiles(user.token) do
      {:error, _} ->
        {:error, user}

      {:ok, [company]} ->
        changeset = client_changeset(existing_client, user, company)
        {:bexio, changeset, user.company_id, existing_client == nil}

      {:ok, []} ->
        {:error, user}
    end
  end

  defp do_register_bexio_client(invalid_status, user), do: {:error, {user, invalid_status}}

  @spec registering_user_valid?(map) ::
          :not_valid | :no_offline_access | :needs_more_scopes | :needs_more_permissions | :valid
  def registering_user_valid?(%{
        refresh_token: refresh_token,
        token: token,
        scopes: scopes
      }) do
    cond do
      refresh_token == nil -> :no_offline_access
      not enough_scopes?(scopes, @needed_scopes) -> :needs_more_scopes
      not enough_permissions?(token) -> :needs_more_permissions
      true -> :valid
    end
  end

  def registering_user_valid?(_user), do: :not_valid

  defp enough_scopes?(scopes, needed),
    do: Enum.all?(needed, fn needed_scope -> Enum.member?(scopes, needed_scope) end)

  defp enough_permissions?(token) do
    {:ok, access_information} = BexioStaticDataFetcher.fetch_permissions(token)

    permissions = access_information.permissions

    can_view_all?(permissions.article) and
      can_view_all?(permissions.contact) and
      can_view_all?(permissions.kb_offer) and
      can_view_all?(permissions.kb_order) and
      can_view_all?(permissions.kb_invoice)
  end

  defp can_view_all?(%{show: :all}), do: true
  defp can_view_all?(_permission), do: false

  defp client_changeset(existing_client, user, company) do
    client =
      Client.changeset(existing_client || %Client{}, %{
        cloud_erp: :bexio,
        erp_id: user.company_id,
        billing_email: company.mail,
        billing_address:
          company.name <>
            "\n" <>
            company.address <>
            "\n" <> company.address_nr <> "\n" <> company.postcode <> " " <> company.city,
        active: true,
        company_name: company.name,
        registration_user_id: user.login_id,
        registration_email: user.email,
        refresh_token: user.refresh_token,
        scopes: user.scopes,
        features: ["clients", "items"],
        action: "registration"
      })

    if client.valid?, do: {:ok, client}, else: {:client_invalid, client.errors}
  end
end
