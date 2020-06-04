defmodule Workflows.Router do
  use Phoenix.Router
  import Phoenix.Controller

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api

    forward "/api", Absinthe.Plug,
      schema: Workflows.Schema

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: Workflows.Schema
    end
end
