defmodule Contact360.Repo.Migrations.CreateUserTable do
  use Ecto.Migration

  def change do
    create table(:users, primary_keys: false) do
      add :login_id, :string, primary_key: true
      add :scopes, {:array, :string}, default: [], null: false
      add :refresh_token, :string # this is only for the syncing user
      add :syncing, :boolean, default: false

      add :given_name, :string
      add :family_name, :string
      add :gender, :string, null: false
      add :locale, :string, null: false, default: "de_CH"
      # not sub, take from user info because this mail is verified
      add :email, :string, null: false

      # list the options for the various variants,
      # for example "kb_offer" => all, kb_order => "own"
      add :permissions, :map, null: false, default: %{}

      timestamps()
    end
  end
end
