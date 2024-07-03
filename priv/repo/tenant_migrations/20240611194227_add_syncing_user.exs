defmodule Contact360.Repo.Migrations.AddSyncingUser do
  use Ecto.Migration

  def up do
    create table(:syncing_users, primary_keys: false) do
      add :login_id, :string, primary_key: true
      add :refresh_token, :string, null: false

      timestamps()
    end

    alter table(:users) do
      remove :refresh_token
      remove :syncing
    end

  end

  def down do
    drop table(:syncing_users)

    alter table(:users) do
      add :refresh_token, :string
      add :syncing, :boolean, default: false
    end
  end
end
