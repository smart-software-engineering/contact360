defmodule Contact360.Scheduler.BexioStaticDataStartup do
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
