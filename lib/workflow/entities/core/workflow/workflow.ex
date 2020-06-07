
defmodule Workflows.Core.Workflow do
  import Ecto.Query
  alias Workflows.Entities.{Event, Action, Entity}
  alias Workflows.Repo
  alias Workflows.Core.Workflow.Actions.{CreateWorkflow, SetName}
  alias Workflows.Core.Workflow.Events.{WorkflowCreated, NameChanged}

  defstruct [:id, :name, :version]

  @type t :: %__MODULE__{
    id: Integer.t(),
    name: String.t(),
    version: Integer.t()
  }

  def get(_context, id) when is_integer(id) do
    get_current_state(id)
  end

  def create(context, %{name: name}) do
    {:ok, result} = Repo.transaction(fn ->
      entity = %Entity{
        version: 0,
        type: "workflow"
      }|> Repo.insert!
      action = %CreateWorkflow{
        id:  entity.id,
        name: name
      }
      send_action(context, entity.id, action)
    end)
    result
  end

  def send_action(context, id, action) do
    {:ok, result} = Repo.transaction(fn ->
      snapshot = get_current_state(id);
      current_version = get_version(snapshot)

      event = dispatch_action(snapshot, action)

      action_row = persist_action(context, id, action)

      persist_event(action_row, event, current_version + 1)

      update_entity_version(id, current_version + 1)

      _apply_event(snapshot, event)
    end)
    result
  end

  defp dispatch_action(state, %CreateWorkflow{id: id, name: name}) do
    cond do
      is_nil(state) -> %WorkflowCreated{
        id: id,
        name: name
      }
      true -> raise "There is already a workflow with id #{id}"
    end
  end

  defp dispatch_action(%__MODULE__{} = _state, %SetName{name: name}) do
    %NameChanged{name: name}
  end

  defp dispatch_action(_state, action) do
    raise "Unknown action type #{action.type}"
  end

  defp get_version(entity) do
    cond do
      is_nil(entity) -> 0
      true -> entity.version
    end
  end

  defp get_current_state(id) do
    Repo.get!(Entity, id)

    query = from e in Event,
        where: e.entity_id == ^id,
        order_by: e.entity_version,
        select: e

    Repo.all(query)
      |> Enum.map(&event_row_to_event/1)
      |> Enum.reduce(nil, fn (event, state) -> _apply_event(state, event) end)
  end

  def event_row_to_event(%Event{} = event_row) do
    module = String.to_existing_atom(event_row.type)

    # Workaround so that we have an struct (the keys are atoms) and not a map (the keys are strings)
    {:ok, payload} = event_row.payload
      |> Poison.encode
      |> (fn {:ok, json} -> json end).()
      |> Poison.decode(as: struct!(module))
    payload
  end

  defp _apply_event(state, event) do
    state = apply_event(state, event)
    %__MODULE__{state | version: state.version + 1}
  end

  defp apply_event(nil, %WorkflowCreated{} = event) do
    %__MODULE__{
      id: event.id,
      name: event.name,
      version: 0
    }
  end

  defp apply_event(%__MODULE__{} = state, %NameChanged{name: name}) do
    %{state | name: name}
  end

  defp apply_event(_, event) do
    raise "Unknown event type #{event.type}"
  end

  defp persist_action(context, entity_id, action) when is_integer(entity_id) do
    %Action{}
    |> Action.changeset(%{
      type: action.__struct__,
      payload: action,
      created_by: context.user_id,
      entity_id: entity_id,
      entity_type: "workflow"
    })
    |> Repo.insert!
  end

  defp persist_event(%Action{} = action, event, entity_version) when is_integer(entity_version) do
    %Event{}
      |> Event.changeset(%{
        action_id: action.id,
        created_by: action.created_by,
        entity_id: action.entity_id,
        entity_type: "workflow",
        type: event.__struct__,
        payload: event,
        entity_version: entity_version
      })
      |> Repo.insert!
  end

  defp update_entity_version(id, new_version) when is_integer(id) and is_integer(new_version) do
    query = from e in Entity,
      where: e.id == ^id,
      update: [set: [version: ^new_version]]
    Repo.update_all(query, [])
  end
end
