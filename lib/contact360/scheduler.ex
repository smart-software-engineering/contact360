defmodule Contact360.Scheduler do
  @moduledoc """
  The Scheduler context.
  """

  alias Contact360.Scheduler.BexioStaticDataSupervisor
  alias Contact360.Clients

  def start_all_schedulers do
    Clients.list_clients()
    |> Enum.each(&start_static_data_scheduler/1)
  end

  def start_static_data_scheduler(client) do
    BexioStaticDataSupervisor.start_scheduler(client.id, client.token)
  end

  def stop_static_data_scheduler(client) do
    BexioStaticDataSupervisor.stop_scheduler(client.id)
  end
end
