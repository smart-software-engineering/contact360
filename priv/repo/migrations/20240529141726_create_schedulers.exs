defmodule Contact360.Repo.Migrations.CreateSchedulers do
  use Ecto.Migration

  def change do
    create table(:schedulers) do
      add :client_id, references(:clients, on_delete: :delete_all)

      add :scheduler_name, :string, null: false
      add :last_run, :naive_datetime
      add :data_synced_last_run, :integer, default: 0, null: false
      add :data_synced_total, :integer, default: 0, null: false
      add :schedule, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:schedulers, [:client_id])
    create index(:schedulers, [:client_id, :scheduler_name])
  end
end
