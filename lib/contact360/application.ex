defmodule Contact360.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application

  alias Contact360.Scheduler
  alias Contact360.Scheduler.BexioStaticDataSupervisor

  @impl true
  def start(_type, _args) do
    children = [
      Contact360Web.Telemetry,
      Contact360.Repo,
      {DNSCluster, query: Application.get_env(:contact360, :dns_cluster_query) || :ignore},
      {Registry, keys: :unique, name: Contact360.Registry},
      {Phoenix.PubSub, name: Contact360.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Contact360.Finch},
      # Start a worker by calling: Contact360.Worker.start_link(arg)
      # {Contact360.Worker, arg},

      # TODO: start bexio supervisor below...
      # Start to serve requests, typically the last entry
      Contact360Web.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Contact360.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_bexio_supervisor do
    children = [
      {BexioStaticDataSupervisor, name: BexioStaticDataSupervisor},
      Supervisor.child_spec({Task, &Scheduler.start_all_schedulers/0},
        restart: :transient
      )
    ]

    opts = [strategy: :rest_for_one]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Contact360Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
