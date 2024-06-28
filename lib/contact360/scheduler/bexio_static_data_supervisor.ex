# This is a PoC Genclient_id,  in reality I need to separate the API calls and the GenServer State
defmodule Contact360.Scheduler.BexioStaticDataSupervisor do
  use DynamicSupervisor

  alias Contact360.Scheduler.BexioStaticDataScheduler

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @doc """
  Starts a scheduler for the given client id.
  """
  def start_scheduler(company_id, refresh_token) do
    DynamicSupervisor.start_child(
      __MODULE__,
      BexioStaticDataScheduler.child_spec(company_id: company_id, refresh_token: refresh_token)
    )
  end

  @impl DynamicSupervisor
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Stops a scheduler for the given client id.
  """
  def stop_scheduler(_company_id) do
    #  DynamicSupervisor.stop(
    #   __MODULE__,
    #   {__MODULE__, client_id: client_id, token: token}
    # )
  end
end
