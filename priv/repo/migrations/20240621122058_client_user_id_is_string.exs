defmodule Contact360.Repo.Migrations.ClientUserIdIsString do
  use Ecto.Migration

  def up do
    alter table(:clients) do
      modify :registration_user_id, :string, null: false
    end
  end

  def down do
    alter table(:clients) do
      remove :registration_user_id
      add :registration_user_id, :integer, null: false
    end
  end
end
