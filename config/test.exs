import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :voomex, VoomexWeb.Endpoint,
  http: [port: 4002],
  server: false

config :voomex, Voomex.SMPP,
  start: false,
  callback_module: Voomex.SMPP.Mock

config :voomex, Voomex.Repo,
  url: System.get_env("DATABASE_URL"),
  database: "voomex_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :voomex, Oban,
  crontab: false,
  queues: false,
  prune: :disabled

# Print only warnings and errors during test
config :logger, level: :warn

if File.exists?("config/#{Mix.env()}.secret.exs") do
  import_config("#{Mix.env()}.secret.exs")
end
