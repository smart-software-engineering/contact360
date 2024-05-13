defmodule Contact360.Repo.Migrations.CreateCompanyProfile do
  use Ecto.Migration

  def change do
    create table(:company_profile, primary_key: false) do
      add :id, :integer, primary_key: true
      add :name, :string
      add :address, :string
      add :address_nr, :string
      add :postcode, :integer
      add :city, :string
      add :has_own_logo, :boolean, null: false
      add :logo_base64, :string
    end
  end
end
