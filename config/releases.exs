import Config

# In addition to the unique values below, when starting
# a node to connect to a MNO/ShortCode pair, make sure to
# export the ENV `RELEASE_NODE` to be unique. This is used
# for erlang to know what nodes are booted
# (via [epmd](https://erlang.org/doc/man/epmd.html).)

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

live_view_salt =
  System.get_env("LIVE_VIEW_SALT") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :voomex, VoomexWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT"))],
  url: [host: System.get_env("HOST"), port: 80],
  secret_key_base: secret_key_base,
  live_view: [signing_salt: live_view_salt],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :voomex, Voomex.Repo, url: System.get_env("DATABASE_URL")

config :voomex, Voomex.SMPP,
  start: true,
  callback_module: Voomex.SMPP.Implementation,
  host: System.get_env("SMPP_HOST"),
  port: String.to_integer(System.get_env("SMPP_PORT")),
  system_id: System.get_env("SMPP_SYSTEM_ID"),
  password: System.get_env("SMPP_PASSWORD"),
  source_addr: System.get_env("SMPP_SOURCE_ADDR"),
  source_ton: 1,
  source_npi: 1,
  dest_ton: 1,
  dest_npi: 1

config :voomex, Oban,
  repo: Voomex.Repo,
  prune: {:maxlen, 10_000},
  queues: [smpp: 10, rapid_sms: 10]

config :logger, :console,
  level: :info,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason
