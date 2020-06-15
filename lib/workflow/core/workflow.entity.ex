defmodule Example.Core.WorkflowEntity do
  use Entities.Entity
  alias Entities.Context
  alias Example.Core.Workflow.Actions
  alias Example.Core.Workflow.Events
  alias Example.Core.Workflow.CreateWorkflow
  alias Example.Core.Workflow.SetName

  defstruct [:id, :name, :version]

  @impl true
  def get_entity_type(), do: "workflow"

  @impl true
  def handle_create(%Context{} = _context, id, %{name: name}) do
    %Actions.CreateWorkflow{
      id: id,
      name: name
    }
  end

  @impl true
  def handle_action(%Context{} = context, %__MODULE__{} = state, %Actions.SetName{} = event),
    do: SetName.handle_action(context, state, event)

  @impl true
  def handle_action(%Context{} = context, state, %Actions.CreateWorkflow{} = action),
    do: CreateWorkflow.handle_action(context, state, action)

  @impl true
  def apply_event(%Context{} = context, nil, %Events.WorkflowCreated{} = event),
    do: CreateWorkflow.apply_event(context, nil, event)

  @impl true
  def apply_event(%Context{} = context, %__MODULE__{} = state, %Events.NameChanged{} = event),
    do: SetName.apply_event(context, state, event)

  @impl true
  def project_event(
        %Context{} = context,
        %__MODULE__{} = state,
        %Events.NameChanged{} = event
      ),
      do: SetName.project_event(context, state, event)

  @impl true
  def project_event(%Context{} = _context, _state, _event) do
  end
end
