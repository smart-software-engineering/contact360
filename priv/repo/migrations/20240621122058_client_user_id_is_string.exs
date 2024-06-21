defmodule Contact360.Repo.Migrations.ClientUserIdIsString do
  use Ecto.Migration

  def change do
    alter table(:clients) do
      modify :registration_user_id, :string, null: false
    end
  end
end
