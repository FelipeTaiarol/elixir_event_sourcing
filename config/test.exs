use Mix.Config

config :pbkdf2_elixir, :rounds, 1

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :workflows, Workflows.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :workflows, Workflows.Repo,
  username: "postgres",
  password: "postgres",
  database: "workflows_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  after_connect: {Postgrex, :query!, ["SET search_path TO entities;", []]},
  priv: "priv/repo/entities"

config :workflows, Workflows.ReadModelRepo,
  username: "postgres",
  password: "postgres",
  database: "workflows_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  after_connect: {Postgrex, :query!, ["SET search_path TO read;", []]},
  priv: "priv/repo/read_model"
