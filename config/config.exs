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
  connections: [
    %{
      mno: "almadar",
      source_addrs: ["10020", "10030"],
      host: "localhost",
      port: 2775,
      system_id: "smppclient1",
      password: "password"
    },
    %{
      mno: "libyana",
      source_addrs: ["10020", "10030"],
      host: "localhost",
      port: 2776,
      system_id: "smppclient1",
      password: "password",
      dest_ton: 0,
      service_type: "www"
    }
  ]

config :voomex, Voomex.RapidSMS,
  connections: [
    %{
      mno: "almadar",
      url: "http://localhost:8002/backend/vumi-almadar/"
    },
    %{
      mno: "libyana",
      url: "http://localhost:8002/backend/vumi-libyana/"
    }
  ]

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
