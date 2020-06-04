alias Workflows.Repo

Ecto.Adapters.SQL.query!(Repo, """
  drop schema public cascade;
""")

Ecto.Adapters.SQL.query!(Repo, """
  create schema public;
""")
