defmodule Contact360.Clients.Client do
  @moduledoc """
  Client schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @email_regex ~r/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/

  schema "clients" do
    field :active, :boolean, default: true
    field :erp_id, :string
    field :cloud_erp, Ecto.Enum, values: [:bexio, :unknown], null: false
    field :registration_user_id, :string
    field :company_name, :string
    field :registration_email, :string
    field :billing_email, :string
    field :billing_address, :string
    field :scopes, {:array, :string}
    field :features, {:array, :string}
    field :refresh_token, :string

    has_many :months, Contact360.Clients.Month
    has_many :schedulers, Contact360.Clients.Scheduler

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [
      :erp_id,
      :company_name,
      :registration_email,
      :billing_email,
      :billing_address,
      :active,
      :registration_user_id,
      :cloud_erp,
      :scopes,
      :features,
      :refresh_token
    ])
    |> validate_required([
      :erp_id,
      :company_name,
      :registration_email,
      :active,
      :registration_user_id,
      :cloud_erp,
      :scopes,
      :features
    ])
    |> unique_constraint([:cloud_erp, :erp_id])
    |> validate_refresh_token()
    |> validate_format(:registration_email, @email_regex)

    # TODO: validate email
  end

  defp validate_refresh_token(%Ecto.Changeset{} = changeset) do
    active? = get_field(changeset, :active, true)

    if active? and get_field(changeset, :refresh_token) == nil do
      add_error(changeset, :refresh_token, "is required")
    else
      changeset
    end
  end
end
