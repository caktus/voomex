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
    environment variable LIVE_VIEW_SALT is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :voomex, VoomexWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT"))],
  url: [host: System.get_env("HOST"), port: 80],
  secret_key_base: secret_key_base,
  live_view: [signing_salt: live_view_salt],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :voomex, Voomex.Repo, url: System.get_env("DATABASE_URL")

config :voomex, Voomex.SMPP,
  start: true,
  callback_module: Voomex.SMPP.Implementation,
  connections: [
    %{
      mno: "almadar",
      source_addr: "10020",
      host: System.get_env("ALMADAR_HOST"),
      port: String.to_integer(System.get_env("ALMADAR_PORT")),
      system_id: System.get_env("ALMADAR_10020_SYSTEM_ID"),
      password: System.get_env("ALMADAR_10020_PASSWORD")
    },
    %{
      mno: "almadar",
      source_addr: "10040",
      host: System.get_env("ALMADAR_HOST"),
      port: String.to_integer(System.get_env("ALMADAR_PORT")),
      system_id: System.get_env("ALMADAR_10040_SYSTEM_ID"),
      password: System.get_env("ALMADAR_10040_PASSWORD")
    },
    %{
      mno: "libyana",
      source_addr: "10020",
      host: System.get_env("LIBYANA_HOST"),
      port: String.to_integer(System.get_env("LIBYANA_PORT")),
      system_id: System.get_env("LIBYANA_10020_SYSTEM_ID"),
      password: System.get_env("LIBYANA_10020_PASSWORD"),
      dest_ton: 0,
      service_type: "www"
    },
    %{
      mno: "libyana",
      source_addr: "10040",
      host: System.get_env("LIBYANA_HOST"),
      port: String.to_integer(System.get_env("LIBYANA_PORT")),
      system_id: System.get_env("LIBYANA_10040_SYSTEM_ID"),
      password: System.get_env("LIBYANA_10040_PASSWORD"),
      dest_ton: 0,
      service_type: "www"
    }
  ]

config :voomex, Voomex.RapidSMS,
  connections: [
    %{
      mno: "almadar",
      url: System.get_env("ALMADAR_RAPIDSMS_URL")
    },
    %{
      mno: "libyana",
      url: System.get_env("LIBYANA_RAPIDSMS_URL")
    }
  ]

config :voomex, Oban,
  repo: Voomex.Repo,
  prune: {:maxlen, 10_000},
  queues: [to_smpp: 10, to_rapidsms: 10]

config :logger, :console,
  level: :info,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason
