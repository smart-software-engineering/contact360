# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :contact360,
  ecto_repos: [Contact360.Repo],
  generators: [timestamp_type: :utc_datetime]

config :triplex, repo: Contact360.Repo

# Configures the endpoint
config :contact360, Contact360Web.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: Contact360Web.ErrorHTML, json: Contact360Web.ErrorJSON],
    layout: false
  ],
  pubsub_server: Contact360.PubSub,
  live_view: [signing_salt: "2F1jIqZc"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :contact360, Contact360.Mailer, adapter: Swoosh.Adapters.Local

# configure oban
config :contact360, Oban,
  engine: Oban.Engines.Basic,
  # could also be that one queue per client is the best, not sure about limitations though
  queues: [default: 10],
  repo: Contact360.Repo

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  contact360: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  contact360: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# should have an ueberauth for local work without any need to login at all, only active in dev...
config :ueberauth, Ueberauth,
  providers: [
    # default scopes are very low, only the sync user needs more access and that will be asked separately
    # during the registration process
    bexio: {Ueberauth.Strategy.Bexio, [default_scope: "openid email profile"]}
  ]

config :ueberauth, Ueberauth.Strategy.Bexio.OAuth,
  client_id: {System, :get_env, ["BEXIO_CLIENT_ID"]},
  client_secret: {System, :get_env, ["BEXIO_CLIENT_SECRET"]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
