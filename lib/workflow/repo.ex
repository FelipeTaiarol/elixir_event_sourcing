defmodule Workflows.Repo do
  use Ecto.Repo,
    otp_app: :workflows,
    adapter: Ecto.Adapters.Postgres
end
