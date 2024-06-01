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
    field :schedule, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(client, attrs) do
    client
    |> Ecto.build_assoc(:schedulers)
    |> cast(attrs, [
      :scheduler_name,
      :last_run,
      :data_synced_last_run,
      :data_synced_total,
      :schedule
    ])
    |> validate_required([:scheduler_name, :data_synced_last_run, :data_synced_total, :schedule])
  end

  @doc false
  def update_changeset(scheduler, attrs) do
    scheduler
    |> cast(attrs, [:last_run, :data_synced_last_run, :data_synced_total, :schedule])
    |> validate_required([:data_synced_last_run, :data_synced_total, :schedule])
  end
end
