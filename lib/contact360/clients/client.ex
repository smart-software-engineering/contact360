defmodule Contact360.Clients.Client do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clients" do
    field :active, :boolean, default: true
    field :company_id, :integer
    field :cloud_erp, Ecto.Enum, values: [:bexio], null: false
    field :registration_user_id, :integer
    field :company_name, :string
    field :registration_email, :string
    field :billing_email, :string
    field :billing_address, :string
    field :scopes, {:array, :string}
    field :features, {:array, :string}

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [
      :company_id,
      :company_name,
      :registration_email,
      :billing_email,
      :billing_address,
      :active,
      :registration_user_id,
      :cloud_erp,
      :scopes,
      :features
    ])
    |> validate_required([
      :company_id,
      :company_name,
      :registration_email,
      :active,
      :registration_user_id,
      :cloud_erp,
      :scopes,
      :features
    ])
    |> unique_constraint(:company_id)

    # TODO: validate email
  end
end
