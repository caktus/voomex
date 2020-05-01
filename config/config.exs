import Config

config :voomex, ecto_repos: [Voomex.Repo]

# Runtime

config :voomex, VoomexWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fqPLXIWkfgs+SzeZVyKHi8aXPart/ZT5uDo+SNvmGiS5FZ3AeO9qQh2i9RQiWBej",
  render_errors: [view: VoomexWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Voomex.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "SECRET_SALT"]

config :voomex, Voomex.SMPP,
  start: true,
  callback_module: Voomex.SMPP.Implementation,
  host: "localhost",
  port: 2775,
  transport_name: "almadar_smpp_transport_10020",
  system_id: "smppclient1",
  password: "password",
  source_addr: "12345",
  source_ton: 1,
  source_npi: 1,
  dest_ton: 1,
  dest_npi: 1

config :voomex, Voomex.RapidSMS, url: "http://localhost:8002/backend/vumi-http/"

config :voomex, Oban,
  repo: Voomex.Repo,
  prune: {:maxlen, 10_000},
  queues: [to_smpp: 10, to_rapidsms: 10]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
if File.exists?("config/#{Mix.env()}.exs") do
  import_config("#{Mix.env()}.exs")
end
