defmodule Contact360.Repo.Migrations.ChangeSyncingLogic do
  use Ecto.Migration

  def change do
    alter table(:clients) do
      add :refresh_token, :string, null: true
    end
  end
end
