defmodule Contact360.Scheduler.BexioStaticDataStartup do
  @moduledoc """
  Temporary solution for the startup of the BexioStaticDataSupervisor. Will be replaced by a oban job that runs on all nodes.
  """

  use Supervisor

  alias Contact360.Scheduler
  alias Contact360.Scheduler.BexioStaticDataSupervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl Supervisor
  def init(_opts) do
    children = [
      {BexioStaticDataSupervisor, name: BexioStaticDataSupervisor},
      Supervisor.child_spec({Task, &Scheduler.start_all_schedulers/0},
        restart: :transient
      )
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
