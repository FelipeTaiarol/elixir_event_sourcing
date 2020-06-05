alias Workflows.Repo
alias Workflows.Entities.{Entity, Event, Action}

Repo.delete_all(Event)
Repo.delete_all(Action)
Repo.delete_all(Entity)

user1 = 1

entity = %Entity{
  version: 0
}

entity = Repo.insert!(entity)

actions = [
  %Action{
    type: "add_task",
    payload: %{
      id: "task1"
    },
    entity_id: entity.id,
    created_by: user1,
  }
]

[action | _] = Enum.map(actions, &Repo.insert!/1)

events = [
  %Event{
    type: "task_added",
    payload: %{
      id: "task1"
    },
    entity_id: entity.id,
    entity_version: 1,
    action_id: action.id,
    created_by: user1,
  }
]

Enum.map(events, &Repo.insert!/1)

Entity.changeset(entity, %{
  version: Enum.count(events)
}) |> Repo.update!
