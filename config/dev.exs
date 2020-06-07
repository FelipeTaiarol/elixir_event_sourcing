use Mix.Config

config :workflows, Workflows.Endpoint,
  http: [port: 4000],
  debug_errors: false,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Configure your database
config :workflows, Workflows.Repo,
  username: "postgres",
  password: "postgres",
  database: "workflows",
  hostname: "localhost",
  pool_size: 10,
  after_connect: {Postgrex, :query!, ["SET search_path TO entities;", []]},
  priv: "priv/repo/entities"

config :workflows, Workflows.ReadModel.Repo,
  username: "postgres",
  password: "postgres",
  database: "workflows",
  hostname: "localhost",
  pool_size: 10,
  after_connect: {Postgrex, :query!, ["SET search_path TO read;", []]},
  priv: "priv/repo/read_model"
