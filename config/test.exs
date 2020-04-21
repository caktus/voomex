use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :voomex, VoomexWeb.Endpoint,
  http: [port: 4002],
  server: false

config :voomex, Voomex.SMPP,
  start: false,
  callback_module: Voomex.SMPP.Mock

# Print only warnings and errors during test
config :logger, level: :warn
