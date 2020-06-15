defmodule Entities.EntityHelpers do
  import Ecto.Query
  alias Entities.Entity.{EventRow, ActionRow, EntityRow}
  alias Example.Repo
  alias Entities.Context

  def persist_action(module, %Context{} = context, entity_id, action)
       when is_integer(entity_id) do
    %ActionRow{}
    |> ActionRow.changeset(%{
      type: action.__struct__,
      payload: action,
      created_by: context.user_id,
      entity_id: entity_id,
      entity_type: module.get_entity_type()
    })
    |> Repo.insert!()
  end

  def persist_event(module, %ActionRow{} = action, event, entity_version)
       when is_integer(entity_version) do
    %EventRow{}
    |> EventRow.changeset(%{
      action_id: action.id,
      created_by: action.created_by,
      entity_id: action.entity_id,
      entity_type: module.get_entity_type(),
      type: event.__struct__,
      payload: event,
      entity_version: entity_version
    })
    |> Repo.insert!()
  end

  def row_to_event_and_context(%EventRow{} = row) do
    module = String.to_existing_atom(row.type)

    # Workaround so that we have an struct (the keys are atoms) and not a map (the keys are strings)
    {:ok, event} =
      row.payload
      |> Poison.encode()
      |> (fn {:ok, json} -> json end).()
      |> Poison.decode(as: struct!(module))

    {event, %Context{user_id: row.created_by}}
  end

  def get_version(entity) do
    cond do
      is_nil(entity) -> 0
      true -> entity.version
    end
  end

  def update_entity_version(id, expected_version, new_version)
       when is_integer(id) and is_integer(expected_version) and is_integer(new_version) do
    query =
      from e in EntityRow,
        where: e.id == ^id,
        update: [set: [version: ^new_version]]

    # TODO: check expected version.
    Repo.update_all(query, [])
  end
end
