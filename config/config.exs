# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :voomex, ecto_repos: [Voomex.Repo]

# Runtime

config :voomex, VoomexWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fqPLXIWkfgs+SzeZVyKHi8aXPart/ZT5uDo+SNvmGiS5FZ3AeO9qQh2i9RQiWBej",
  render_errors: [view: VoomexWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Voomex.PubSub, adapter: Phoenix.PubSub.PG2]

config :voomex, Voomex.SMPP,
  start: true,
  callback_module: Voomex.SMPP.Implementation,
  host: "localhost",
  port: 2775,
  system_id: "smppclient1",
  password: "password",
  source_addr: "12345",
  source_ton: 1,
  source_npi: 1,
  dest_ton: 1,
  dest_npi: 1

config :voomex, Oban,
  repo: Voomex.Repo,
  prune: {:maxlen, 10_000},
  queues: [smpp: 10, rapid_sms: 10]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
