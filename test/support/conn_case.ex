defmodule Example.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      alias Example.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint Example.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Example.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Example.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
