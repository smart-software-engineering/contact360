defmodule Contact360.Scheduler do
  @moduledoc """
  The Scheduler context.
  """

  alias Contact360.Clients
  alias Contact360.Scheduler.BexioStaticDataSupervisor

  def start_all_schedulers do
    active_clients = Clients.list_active_clients()
    Enum.each(active_clients, &start_static_data_scheduler/1)
  end

  def start_static_data_scheduler(%{erp_id: erp_id, refresh_token: refresh_token}) do
    BexioStaticDataSupervisor.start_scheduler(erp_id, refresh_token)
  end

  def stop_static_data_scheduler(%{erp_id: erp_id}) do
    BexioStaticDataSupervisor.stop_scheduler(erp_id)
  end
end
