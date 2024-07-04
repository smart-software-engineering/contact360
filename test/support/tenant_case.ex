defmodule Contact360.TenantCase do
  use ExUnit.CaseTemplate

  setup_all _tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Contact360.Repo)
    # we are setting :auto here so that the data persists for all tests,
    # normally (with :shared mode) every process runs in a transaction
    # and rolls back when it exits. setup_all runs in a distinct process
    # from each test so the data doesn't exist for each test.
    Ecto.Adapters.SQL.Sandbox.mode(Contact360.Repo, :auto)

    # TODO create one tenant per ERP and not more...
    changeset = Contact360.Clients.Client.changeset(%Contact360.Clients.Client{}, %{
      refresh_token: "rft",
      erp_id: "123456",
      company_name: "example",
      registration_email: "unknown@nomandsland.xxx",
      registration_user_id: "1",
      cloud_erp: :bexio,
      scopes: [
        "kb_invoice_show",
        "openid",
        "offline_access",
        "contact_show",
        "note_show",
        "kb_offer_show",
        "kb_order_show"
      ],
      features: ["clients", "items"]
    })
    {:ok, tenant} = Contact360.Clients.create_client({:bexio, changeset, "123456", true})

    on_exit(fn ->
      # this callback needs to checkout its own connection since it
      # runs in its own process
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Contact360.Repo)
      Ecto.Adapters.SQL.Sandbox.mode(Contact360.Repo, :auto)

      # we also need to re-fetch the %Tenant struct since Ecto otherwise
      # complains it's "stale"
      tenant = Contact360.Clients.get_client_by_erp_and_erp_id(tenant.cloud_erp, tenant.erp_id)
      Contact360.Clients.delete_client(tenant)
      :ok
    end)

    [tenant: tenant]
  end
end
