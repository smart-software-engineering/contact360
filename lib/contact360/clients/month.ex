defmodule Contact360.Clients.Month do
  use Ecto.Schema
  import Ecto.Changeset

  alias Contact360.Clients.Client

  schema "client_months" do
    belongs_to :client, Client

    field :month, :integer
    field :year, :integer
    field :active_users, :integer
    field :invoice_date, :date
    field :payed_date, :date
    field :bexio_ref, :string
    field :unchargeable, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(client, attrs) do
    client
    |> Ecto.build_assoc(:months)
    |> cast(attrs, [
      :year,
      :month,
      :active_users,
      :invoice_date,
      :payed_date,
      :bexio_ref,
      :unchargeable
    ])
    |> validate_required([:year, :month, :active_users, :unchargeable])
  end

  @doc false
  def update_changeset(month, attrs) do
    month
    |> cast(attrs, [:active_users, :invoice_date, :payed_date, :bexio_ref, :unchargeable])
    |> validate_required([:active_users, :unchargeable])
  end
end
