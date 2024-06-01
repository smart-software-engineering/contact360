defmodule Contact360.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :cloud_erp, :string, null: false
      add :company_id, :string, null: false
      add :company_name, :string
      add :registration_email, :string, null: false
      add :registration_user_id, :integer, null: false
      add :billing_email, :string
      add :billing_address, :string
      add :active, :boolean, default: true, null: false
      add :features, {:array, :string}
      add :scopes, {:array, :string}

      timestamps(type: :utc_datetime)
    end

    create unique_index(:clients, [:company_id])
  end
end
