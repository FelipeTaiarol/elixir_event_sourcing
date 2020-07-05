defmodule Entities.Supervisor do
  alias Entities.Context

  def start_link() do
    IO.puts("Starting supervisor")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  @spec entity_process(any, integer, Context.t()) :: pid()
  def entity_process(entity_module, entity_id, context) do
    case start_child(entity_module, entity_id, context) do
      {:ok, pid} ->
        IO.puts("Entity process started #{inspect(entity_module)} #{entity_id}")
        pid

      {:error, {:already_started, pid}} ->
        pid
    end
  end

  defp start_child(entity_module, entity_id, context) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {entity_module, {entity_id, context}}
    )
  end
end
