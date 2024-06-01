defmodule Contact360.Repo.Migrations.CreateClientMonths do
  use Ecto.Migration

  def change do
    create table(:client_months) do
      add :year, :integer, nullable: false
      add :month, :integer, nullable: false
      # at the end of the month
      add :active_users, :integer, nullable: false, default: 1
      add :invoice_date, :date, nullable: false
      add :payed_date, :date
      add :bexio_ref, :string
      add :client_id, references(:clients, on_delete: :delete_all)
      add :unchargeable, :boolean, default: false, nullable: false

      timestamps(type: :utc_datetime)
    end

    create index(:client_months, [:client_id, :year, :month])
  end
end
