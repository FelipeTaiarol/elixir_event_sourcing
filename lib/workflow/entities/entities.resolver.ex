defmodule Workflows.Entities.Resolver do
  alias Workflows.Repo
  alias Workflows.Entities.{Entity, Event, Action}

  defmodule Workflows.Entities.Resolver.EventTypeAndPayload do
    defstruct [:name, :payload]
  end

  def get_events(_, _, _) do
    events = Repo.all(Event)
    {:ok, events}
  end

  def get_entities(_, _, _) do
    entities = Repo.all(Entity)
    {:ok, entities}
  end

  def save_action(args) do
    IO.puts "save action #{inspect args}"
    user_id = 1
    args = Map.put(args, :created_by, user_id)

    entity = Repo.get_by!(Entity, id: args.entity_id)

    Repo.transaction(fn ->
      action = persist_action(args)

      events = dispatch_action(action)

      persist_events(action, events, entity.version)

      new_version = entity.version + Enum.count(events);

      update_entity_version(entity, new_version)

      IO.puts "Action #{inspect action} #{inspect events}"

      new_version
    end)
  end

  defp persist_action(args) do
    %Action{}
    |> Action.changeset(args)
    |> Repo.insert!
  end

  defp persist_events(%Action{} = action, events, entity_version) do
    for {event, counter} <- Enum.with_index(events) do
      %Event{
        action_id: action.id,
        created_by: action.created_by,
        entity_id: action.entity_id,
        type: event.type,
        payload: event.payload,
        entity_version: entity_version + counter + 1
      } |> Event.changeset(%{})
        |> Repo.insert!
    end
  end

  defp update_entity_version(%Entity{} = entity, new_version) do
    Entity.changeset(entity, %{
      version: new_version
    }) |> Repo.update!
  end

  def dispatch_action(%{type: "add_task"} = action) do
    [%{type: "task_added", payload: action.payload }]
  end

  def dispatch_action(action) do
    raise "Unknown action type #{action.type}"
  end
end
