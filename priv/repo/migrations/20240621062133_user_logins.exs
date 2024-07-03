defmodule Contact360.Repo.Migrations.UserLogins do
  use Ecto.Migration

  def change do
    # TODO:
    # what's an acceptable timeframe to keep track of this user logins? need to find out and create a scheduler to simply remove them
    # regularly. probably can remove it as soon as the corresponding bill has been deleted.

    # probably no primary key because it doesn't make sense as all fields would be the primary key
    create table(:user_logins, primary_key: false) do
      add :client_id, references(:clients), null: false
      add :login_id, :string, null: false
      add :login_date, :naive_datetime, null: false
    end
  end
end
