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

  Raises `Ecto.NoResultsError` if the Client does not exist.

  ## Examples

      iex> get_client!(123)
      %Client{}

      iex> get_client!(456)
      ** (Ecto.NoResultsError)

  """
  def get_client!(id), do: Repo.get!(Client, id)

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
    Repo.delete(client)
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
  Returns the list of client_months.

  ## Examples

      iex> list_client_months()
      [%Month{}, ...]

  """
  def list_client_months do
    Repo.all(Month)
  end

  @doc """
  Gets a single month.

  Raises `Ecto.NoResultsError` if the Month does not exist.

  ## Examples

      iex> get_month!(123)
      %Month{}

      iex> get_month!(456)
      ** (Ecto.NoResultsError)

  """
  def get_month!(id), do: Repo.get!(Month, id)

  @doc """
  Creates a month.

  ## Examples

      iex> create_month(%{field: value})
      {:ok, %Month{}}

      iex> create_month(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_month(attrs \\ %{}) do
    %Month{}
    |> Month.changeset(attrs)
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
    |> Month.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a month.

  ## Examples

      iex> delete_month(month)
      {:ok, %Month{}}

      iex> delete_month(month)
      {:error, %Ecto.Changeset{}}

  """
  def delete_month(%Month{} = month) do
    Repo.delete(month)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking month changes.

  ## Examples

      iex> change_month(month)
      %Ecto.Changeset{data: %Month{}}

  """
  def change_month(%Month{} = month, attrs \\ %{}) do
    Month.changeset(month, attrs)
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
  Gets a single scheduler.

  Raises `Ecto.NoResultsError` if the Scheduler does not exist.

  ## Examples

      iex> get_scheduler!(123)
      %Scheduler{}

      iex> get_scheduler!(456)
      ** (Ecto.NoResultsError)

  """
  def get_scheduler!(id), do: Repo.get!(Scheduler, id)

  @doc """
  Creates a scheduler.

  ## Examples

      iex> create_scheduler(%{field: value})
      {:ok, %Scheduler{}}

      iex> create_scheduler(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_scheduler(attrs \\ %{}) do
    %Scheduler{}
    |> Scheduler.changeset(attrs)
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
    |> Scheduler.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a scheduler.

  ## Examples

      iex> delete_scheduler(scheduler)
      {:ok, %Scheduler{}}

      iex> delete_scheduler(scheduler)
      {:error, %Ecto.Changeset{}}

  """
  def delete_scheduler(%Scheduler{} = scheduler) do
    Repo.delete(scheduler)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking scheduler changes.

  ## Examples

      iex> change_scheduler(scheduler)
      %Ecto.Changeset{data: %Scheduler{}}

  """
  def change_scheduler(%Scheduler{} = scheduler, attrs \\ %{}) do
    Scheduler.changeset(scheduler, attrs)
  end
end
