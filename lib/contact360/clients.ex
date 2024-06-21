defmodule Contact360.Clients do
  @moduledoc """
  The Clients context.
  """

  import Ecto.Query, warn: false
  alias Contact360.Repo

  alias Contact360.Clients.Client
  alias Contact360.Clients.Month

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
  Returns the number of active clients currently registered with the system.

  ## Examples

      iex> count_active_clients()
      13

  """
  def count_active_clients do
    query =
      from c in Client,
        where: c.active == true,
        select: count(c)

    query
    |> Repo.all()
    |> hd()
  end

  @doc """
  Gets a single client for a given erp and company id.

  ## Examples

      iex> get_client(:bexio, "123")
      %Client{}

      iex> get_client(:bexio, "456")
      nil

  """
  def get_client_by_erp_and_erp_id(erp, erp_id),
    do: Repo.get_by(Client, cloud_erp: erp, erp_id: erp_id)

  @doc """
  Creates a client.

  ## Examples

      iex> register_client(%{field: value})
      {:ok, %Client{}}

      iex> register_client(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_bexio_client(user) do
    dbg()

    registering_user_valid?(user)

    client =
      Client.changeset(%Client{}, %{
        cloud_erp: :bexio,
        erp_id: user.company_id,
        active: true,
        registration_user_id: user.login_id,
        company_name: "not yet defined",
        registration_email: user.email,
        scopes: [],
        features: ["clients", "items"]
      })

    if client.valid? do
      Triplex.create_schema(tenant_name(client.data), Repo, fn tenant, repo ->
        Triplex.migrate(tenant, repo) |> IO.inspect(label: "Migration")
        repo.insert(client)
      end)
    else
      {:error, client}
    end
  end

  defp registering_user_valid?(nil), do: false

  defp registering_user_valid?(%{refresh_token: refresh_token, token: token, scopes: scopes}) do
    refresh_token != nil and enough_scopes?(scopes, @needed_scopes) and enough_permissions?(token)
  end

  defp enough_scopes?(scopes, needed),
    do: Enum.all?(needed, fn needed_scope -> Enum.member?(scopes, needed_scope) end)

  defp enough_permissions?(token) do
    {:ok, permissions} = BexioApiClient.Others.get_access_information(token)
    dbg()
    # can_view_all?(permissions.kb_article_order) and
    can_view_all?(permissions.article) and
      can_view_all?(permissions.contact) and
      can_view_all?(permissions.kb_offer) and
      can_view_all?(permissions.kb_order) and
      can_view_all?(permissions.kb_invoice) and
      can_view_all?(permissions.stockmanagement)
  end

  defp can_view_all?(%{view: :all}), do: true
  defp can_view_all?(_), do: false

  defp tenant_name(%{erp_id: erp_id, cloud_erp: cloud_erp}),
    do: "#{cloud_erp}_#{erp_id}"

  @doc """
  Updates a client.

  ## Examples

      iex> update_client(client, %{field: new_value})
      {:ok, %Client{}}

      iex> update_client(client, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_client(%Client{} = client, attrs) do
    client
    |> Client.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a client.

  ## Examples

      iex> delete_client(client)
      {:ok, %Client{}}

      iex> delete_client(client)
      {:error, %Ecto.Changeset{}}

  """
  def delete_client(%Client{} = client) do
    undeletable? =
      list_months_for_client(client.id)
      |> Enum.any?(fn m -> not m.unchargeable and m.active_users > 0 and m.bexio_ref == nil end)

    if undeletable? do
      {:error, "Client has still active months!"}
    else
      Repo.delete(client)
      Triplex.drop(tenant_name(client))
    end
  end

  @doc """
  Returns the list of months for a specific client.

  ## Examples

      iex> list_months_for_client(%Client{})
      [%Month{}, ...]

  """
  def list_months_for_client(%Client{id: id}), do: list_months_for_client(id)

  def list_months_for_client(client_id) do
    q = from m in Month, where: m.client_id == ^client_id, order_by: [desc: :year, desc: :month]
    Repo.all(q)
  end

  @doc """
  Returns the list of open for invoice months

  ## Examples

      iex> list_invoiceable_months()
      [%Month{}, ...]

  """
  def list_invoiceable_months() do
    q =
      from m in Month,
        where: is_nil(m.invoice_date),
        where: m.unchargeable == false,
        where: m.active_users > 0,
        order_by: [asc: :year, asc: :month]

    Repo.all(q)
  end

  @doc """
  Gets a single month.

  Raises `Ecto.NoResultsError` if the Month does not exist.

  ## Examples

      iex> get_month(123, 2024, 3)
      %Month{}

      iex> get_month(456, 2024, 3)
      nil

  """
  def get_month(client_id, year, month),
    do: Repo.get_by(Month, client_id: client_id, year: year, month: month)

  @doc """
  Creates a month.

  ## Examples

      iex> create_month(%Client{id: id}, %{field: value})
      {:ok, %Month{}}

      iex> create_month(%Client{id: id}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_month(%Client{} = client, attrs \\ %{}) do
    client
    |> Month.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates the active users for a given month

  ## Examples

      iex> update_month_active_users(%Client{id: id})
      {:ok, 1}

  """
  def update_month_active_users(_client) do
    # this will be updated once a day and simply check how many users had the last login
    # within a given month
    {:ok, 0}
  end

  @doc """
  Updates a month (with invoice information from bexio actually).

  ## Examples

      iex> update_month(month, %{field: new_value})
      {:ok, %Month{}}

      iex> update_month(month, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_month(%Month{} = month, attrs) do
    month
    |> Month.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking month changes.

  ## Examples

      iex> change_month(month)
      %Ecto.Changeset{data: %Month{}}

  """
  def change_month(%Month{} = month, attrs \\ %{}) do
    Month.update_changeset(month, attrs)
  end

  alias Contact360.Clients.Scheduler

  @doc """
  Returns the list of schedulers.

  ## Examples

      iex> list_schedulers()
      [%Scheduler{}, ...]

  """
  def list_schedulers do
    Repo.all(Scheduler)
  end

  @doc """
  Creates a scheduler.

  ## Examples

      iex> create_scheduler(%{field: value})
      {:ok, %Scheduler{}}

      iex> create_scheduler(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_scheduler(%Client{} = client, attrs \\ %{}) do
    client
    |> Scheduler.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a scheduler.

  ## Examples

      iex> update_scheduler(scheduler, %{field: new_value})
      {:ok, %Scheduler{}}

      iex> update_scheduler(scheduler, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_scheduler(%Scheduler{} = scheduler, attrs) do
    scheduler
    |> Scheduler.update_changeset(attrs)
    |> Repo.update()
  end
end
