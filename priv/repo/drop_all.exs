alias Example.Repo

Ecto.Adapters.SQL.query!(Repo, """
  drop schema if exists entities cascade;
""")

Ecto.Adapters.SQL.query!(Repo, """
  drop schema if exists read cascade;
""")

Ecto.Adapters.SQL.query!(Repo, """
  create schema read;
""")

Ecto.Adapters.SQL.query!(Repo, """
  create schema entities;
""")
