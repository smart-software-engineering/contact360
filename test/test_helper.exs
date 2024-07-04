ExUnit.start(exclude: [:skip])

Contact360.Clients.list_active_clients() |> Enum.each(&Contact360.Clients.delete_client/1)

Ecto.Adapters.SQL.Sandbox.mode(Contact360.Repo, :manual)
