defmodule Example.Core.Workflow.SetName do
  alias Entities.Context
  alias Example.Core.Workflow.Actions.SetName
  alias Example.Core.Workflow.Events.NameChanged
  alias Example.Core.WorkflowEntity

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
