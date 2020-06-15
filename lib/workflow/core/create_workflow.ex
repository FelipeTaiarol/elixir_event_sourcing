defmodule Example.Core.Workflow.CreateWorkflow do
  alias Entities.Context
  alias Example.Core.Workflow.Actions.CreateWorkflow
  alias Example.Core.Workflow.Events.WorkflowCreated
  alias Example.Core.WorkflowEntity

  def handle_action(%Context{} = _context, state, %CreateWorkflow{id: id, name: name}) do
    cond do
      is_nil(state) ->
        %WorkflowCreated{
          id: id,
          name: name
        }

      true ->
        raise "There is already a workflow with id #{id}"
    end
  end

  def apply_event(%Context{} = _context, nil, %WorkflowCreated{} = event) do
    %WorkflowEntity{
      id: event.id,
      name: event.name,
      version: 0
    }
  end

  def project_event(
        %Context{} = _context,
        %WorkflowEntity{} = _state,
        %WorkflowCreated{} = event
      ) do
    IO.puts("PROJECT #{inspect(event)}")
  end
end
