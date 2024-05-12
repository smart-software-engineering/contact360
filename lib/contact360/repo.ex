defmodule Contact360.Repo do
  use Ecto.Repo,
    otp_app: :contact360,
    adapter: Ecto.Adapters.Postgres
end
