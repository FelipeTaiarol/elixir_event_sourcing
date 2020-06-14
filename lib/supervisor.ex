defmodule Test.Supervisor do
  def start_link() do
    IO.puts("Starting Supervisor")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def entity_process(entity_id) do
    case start_child(entity_id) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(entity_id) do
    DynamicSupervisor.start_child(__MODULE__, {Test, entity_id})
  end
end
