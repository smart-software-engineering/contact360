defmodule Contact360.ClientsFixtures do
  @doc """
  Generate a month.
  """
  def month_fixture(client, attrs \\ %{}) do
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
  def scheduler_fixture(client, attrs \\ %{}) do
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
