defmodule Entities.Supervisor do
  def start_link() do
    IO.puts("Starting Entity Supervisor")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def entity_process(entity_module, entity_id, context) do
    case start_child(entity_module, entity_id, context) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(entity_module, entity_id, context) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {entity_module, {entity_id, context}}
    )
  end
end
