defmodule Contact360.ClientsFixtures do
  alias Ecto.Repo

  @moduledoc """
  This module defines test helpers for creating
  entities via the `Contact360.Clients` context.
  """

  @doc """
  Generate a client.
  """
  def client_fixture(attrs \\ %{}) do
    erp_id = System.unique_integer([:positive]) |> to_string()

    attrs =
      attrs
      |> Enum.into(%{
        active: true,
        billing_address: "some billing_address\r\nHinter dem Walde\r\nInnerschweiz",
        billing_email: "abc@world.com",
        erp_id: erp_id,
        company_name: "some company_name",
        registration_email: "def@world.com",
        cloud_erp: "bexio",
        scopes: [],
        features: ["contacts", "items"],
        registration_user_id: 1
      })

    changeset = Contact360.Clients.Client.changeset(%Contact360.Clients.Client{}, attrs)

    {:ok, client} = Repo.insert(changeset)

    client
  end

  @doc """
  Generate a month.
  """
  def month_fixture(client \\ client_fixture(), attrs \\ %{}) do
    month = :rand.uniform(12)
    year = :rand.uniform(25) + 2000

    attrs =
      Enum.into(attrs, %{
        active_users: 3,
        bexio_ref: "some bexio_ref",
        invoice_date: ~D[2024-05-28],
        month: month,
        payed_date: ~D[2024-05-28],
        year: year
      })

    {:ok, month} = Contact360.Clients.create_month(client, attrs)

    month
  end

  @doc """
  Generate a scheduler.
  """
  def scheduler_fixture(client \\ client_fixture(), attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        last_run: ~N[2024-05-28 14:17:00],
        data_synced_last_run: 0,
        data_synced_total: 0,
        scheduler_name: :bexio_contacts,
        schedule: "daily"
      })

    {:ok, scheduler} = Contact360.Clients.create_scheduler(client, attrs)

    scheduler
  end
end
