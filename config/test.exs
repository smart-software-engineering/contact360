import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :contact360, Contact360.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "contact360_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :contact360, Contact360Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Ts01SiQ2yUWvJledVJvj1T3iBGtbYI89W0toJnmJ6ljhwkSbHpUYRLYmg1h78xlE",
  server: false

# In test we don't send emails.
config :contact360, Contact360.Mailer, adapter: Swoosh.Adapters.Test

# prevent oban from running jobs and plugins
config :contact360, Oban, testing: :inline

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Enable the fake API, which involves two changes: base url for the bexio client and the faker API
config :contact360, :bexio_api_faker, true
config :bexio_api_client, :req_options, base_url: "http://localhost:4002/bexio-faker/api/"
config :bexio_api_client, :idp_url, "http://localhost:4002/bexio-faker/idp/"

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true
