defmodule Contact360.Repo.Migrations.AddSyncingUser do
  use Ecto.Migration

  def change do
    create table(:syncing_users, primary_keys: false) do
      add :login_id, :string, primary_key: true
      add :refresh_token, :string, null: false

      timestamps()
    end

    alter table(:users) do
      drop :refresh_token
      drop :syncing

      timestamps()
    end

  end
end
