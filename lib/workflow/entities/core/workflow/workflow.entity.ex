
defmodule Workflows.Core.WorkflowEntity do
  use Entities.Entity
  alias Workflows.Core.Workflow.Actions.{CreateWorkflow, SetName}
  alias Workflows.Core.Workflow.Events.{WorkflowCreated, NameChanged}

  defstruct [:id, :name, :version]

  @impl true
  def get_entity_type(), do:  "workflow"

  @impl true
  def handle_create(_context, id, args) do
    %CreateWorkflow{
      id: id,
      name: args.name
    }
  end

  @impl true
  def handle_action(%__MODULE__{} = _state, %SetName{name: name}) do
    %NameChanged{name: name}
  end

  @impl true
  def handle_action(state, %CreateWorkflow{id: id, name: name}) do
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

  @impl true
  def apply_event(nil, %WorkflowCreated{} = event) do
    %__MODULE__{
      id: event.id,
      name: event.name,
      version: 0
    }
  end

  @impl true
  def apply_event(%__MODULE__{} = state, %NameChanged{name: name}) do
    %{state | name: name}
  end
end
