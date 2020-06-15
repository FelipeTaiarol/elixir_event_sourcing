defmodule Workflows.Core.Workflow.SetName do
  alias Entities.Context
  alias Workflows.Core.Workflow.Actions.SetName
  alias Workflows.Core.Workflow.Events.NameChanged
  alias Workflows.Core.WorkflowEntity

  def handle_action(%Context{} = _context, %WorkflowEntity{} = _state, %SetName{name: name}) do
    %NameChanged{name: name}
  end

  def apply_event(%Context{} = _context, %WorkflowEntity{} = state, %NameChanged{
        name: name
      }) do
    %WorkflowEntity{state | name: name}
  end

  def project_event(
        %Context{} = _context,
        %WorkflowEntity{} = _state,
        %NameChanged{} = event
      ) do
    IO.puts("PROJECT #{inspect(event)}")
  end
end
