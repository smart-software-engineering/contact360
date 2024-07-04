defmodule Contact360.TenantCase do
  use ExUnit.CaseTemplate

  setup_all tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Contact360.Repo)
    # we are setting :auto here so that the data persists for all tests,
    # normally (with :shared mode) every process runs in a transaction
    # and rolls back when it exits. setup_all runs in a distinct process
    # from each test so the data doesn't exist for each test.
    Ecto.Adapters.SQL.Sandbox.mode(Contact360.Repo, :auto)

    # TODO create one tenant per ERP and not more...
    {:ok, tenant} = Contact360.Clients.create(%{name: "example"})

    on_exit(fn ->
      # this callback needs to checkout its own connection since it
      # runs in its own process
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Contact360.Repo)
      Ecto.Adapters.SQL.Sandbox.mode(Contact360.Repo, :auto)

      # we also need to re-fetch the %Tenant struct since Ecto otherwise
      # complains it's "stale"
      tenant = Contact360.Tenant.get!(tenant.id)
      Contact360.Tenant.delete(tenant)
      :ok
    end)

    [tenant: tenant]
  end
end
