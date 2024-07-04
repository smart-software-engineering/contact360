defmodule Contact360.Clients do
  @moduledoc """
  The Clients context.
  """

  import Ecto.Query, warn: false
  alias Contact360.Repo

  alias Contact360.Clients.BexioRegistration
  alias Contact360.Clients.Client
  alias Contact360.Clients.Month
  alias Contact360.Clients.Scheduler

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
  List all active clients that need to be scheduled for static data retrieval during startup
  """
  def list_active_clients do
    query =
      from c in Client,
        where: c.active == true,
        order_by: [asc: :company_name, asc: :erp_id],
        select: c

    Repo.all(query)
  end

  @doc """
  Gets a single client for a given erp and company id.

  ## Examples

      iex> get_client_by_erp_and_erp_id(:bexio, "123")
      %Client{}

      iex> get_client_by_erp_and_erp_id(:bexio, "456")
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
    case BexioRegistration.register_bexio_client(user) do
      {:bexio, changeset, company_id, insert?} ->
        create_client({:bexio, changeset, company_id, insert?})

      {:error, error} ->
        {:error, error}
    end
  end

  def create_client({erp, changeset, company_id, insert?}) do
    case create_triplex_if_needed(erp, company_id) do
      {:ok, _tenant} -> upsert_client(changeset, insert?)
      {:error, error} -> {:error, error}
    end
  end

  defp upsert_client(client, true), do: Repo.insert(client)
  defp upsert_client(client, false), do: Repo.update(client)

  def create_triplex_if_needed(erp, id) do
    triplex_id = tenant_name(erp, id)

    if Triplex.exists?(triplex_id) do
      {:ok, triplex_id}
    else
      Triplex.create(triplex_id)
    end
  end

  def tenant_name(cloud_erp, erp_id), do: "#{cloud_erp}_#{erp_id}"

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
      triplex_id = tenant_name(client.cloud_erp, client.erp_id)
      if Triplex.exists?(triplex_id), do: Triplex.drop(triplex_id)
      {:ok, client}
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
  def list_invoiceable_months do
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
