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

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(month, attrs) do
    month
    |> cast(attrs, [:year, :month, :active_users, :invoice_date, :payed_date, :bexio_ref])
    |> validate_required([:year, :month, :active_users])
    # probably wrong, need to think about that one
    |> cast_assoc(:client)
  end
end
