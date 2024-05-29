defmodule Contact360.Clients.Scheduler do
  use Ecto.Schema
  import Ecto.Changeset

  alias Contact360.Clients.Client

  schema "schedulers" do
    belongs_to :client, Client

    field :scheduler_name, Ecto.Enum, values: [:bexio_contacts, :bexio_items], null: false
    field :last_run, :naive_datetime
    field :data_synced_last_run, :integer, default: 0
    field :data_synced_total, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scheduler, attrs) do
    scheduler
    |> cast(attrs, [:scheduler_name, :last_run, :data_synced_last_run, :data_synced_total])
    |> validate_required([:scheduler_name, :data_synced_last_run, :data_synced_total])
    # probably wrong, need to think about that one
    |> cast_assoc([:client])
  end
end
