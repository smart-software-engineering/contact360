defmodule Contact360.ClientsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Contact360.Clients` context.
  """

  @doc """
  Generate a client.
  """
  def client_fixture(attrs \\ %{}) do
    {:ok, client} =
      attrs
      |> Enum.into(%{
        active: true,
        billing_address: "some billing_address\r\nHinter dem Walde\r\nInnerschweiz",
        billing_email: "abc@world.com",
        company_id: 42,
        company_name: "some company_name",
        registration_email: "def@world.com",
        cloud_erp: "bexio",
        # TODO check in docs bexio
        scopes: ["..."],
        features: ["contacts", "items"],
        registration_user_id: 1
      })
      |> Contact360.Clients.create_client()

    client
  end

  @doc """
  Generate a month.
  """
  def month_fixture(attrs \\ %{}) do
    attrs =
      Map.put_new_lazy(attrs, :client, fn ->
        Map.from_struct(client_fixture())
      end)

    {:ok, month} =
      attrs
      |> Enum.into(%{
        active_users: 3,
        bexio_ref: "some bexio_ref",
        invoice_date: ~D[2024-05-28],
        month: 1,
        payed_date: ~D[2024-05-28],
        year: 2024
      })
      |> Contact360.Clients.create_month()

    month
  end

  @doc """
  Generate a scheduler.
  """
  def scheduler_fixture(attrs \\ %{}) do
    attrs =
      Map.put_new_lazy(attrs, :client, fn ->
        Map.from_struct(client_fixture())
      end)

    {:ok, scheduler} =
      attrs
      |> Enum.into(%{
        last_run: ~N[2024-05-28 14:17:00],
        data_synced_last_run: 0,
        data_synced_total: 0,
        scheduler_name: :bexio_contacts
      })
      |> Contact360.Clients.create_scheduler()

    scheduler
  end
end
