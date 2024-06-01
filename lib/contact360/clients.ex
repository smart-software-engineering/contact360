defmodule Contact360.Clients do
  @moduledoc """
  The Clients context.
  """

  import Ecto.Query, warn: false
  alias Contact360.Repo

  alias Contact360.Clients.Client

  @doc """
  Returns the list of clients.

  ## Examples

      iex> list_clients()
      [%Client{}, ...]

  """
  def list_clients do
    Repo.all(Client)
  end

  @doc """
  Gets a single client.

  ## Examples

      iex> get_client(123)
      %Client{}

      iex> get_client(456)
      nil

  """
  def get_client(id), do: Repo.get(Client, id) |> Repo.preload(:schedulers)

  @doc """
  Gets a single client by it's company id and cloud_erp system.

  ## Examples

      iex> get_client_by_cloud_erp_and_company_id(:bexio, "123")
      %Client{}

      iex> get_client_by_cloud_erp_and_company_id(:unknown_erp, "123")
      nil

  """
  def get_client_by_cloud_erp_and_company_id(cloud_erp, company_id),
    do:
      Repo.get_by(Client, company_id: company_id, cloud_erp: cloud_erp)
      |> Repo.preload(:schedulers)

  @doc """
  Creates a client.

  ## Examples

      iex> create_client(%{field: value})
      {:ok, %Client{}}

      iex> create_client(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_client(attrs \\ %{}) do
    %Client{}
    |> Client.changeset(attrs)
    |> Repo.insert()
  end

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
      list_months(client.id)
      |> Enum.any?(fn m -> not m.unchargeable and m.active_users > 0 and m.bexio_ref == nil end)

    if not undeletable? do
      Repo.delete(client)
    else
      {:error, "Client has still active months!"}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking client changes.

  ## Examples

      iex> change_client(client)
      %Ecto.Changeset{data: %Client{}}

  """
  def change_client(%Client{} = client, attrs \\ %{}) do
    Client.changeset(client, attrs)
  end

  alias Contact360.Clients.Month

  @doc """
  Returns the list of months for a specific client.

  ## Examples

      iex> list_client_months()
      [%Month{}, ...]

  """
  def list_months(%Client{id: id}), do: list_months(id)

  def list_months(client_id) do
    q = from m in Month, where: m.client_id == ^client_id
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
  Updates a month.

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
