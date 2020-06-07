defmodule Entities.Entity do
  import Ecto.Query
  alias Entities.Entity.{EventRow, ActionRow, EntityRow}
  alias Workflows.Repo

  @callback handle_action(state :: any, action :: any) :: any
  @callback apply_event(state :: any, event :: any) :: any
  @callback get_entity_type() :: String.t()
  @callback handle_create(context :: any, id :: Integer.t(), args :: any) :: any

  defmacro __using__([]) do
    quote do
      @behaviour Entities.Entity

      def create(context, args) do
        Entities.Entity.create(__MODULE__, context, args)
      end

      def get(context, id) when is_integer(id) do
        Entities.Entity.get(__MODULE__, context, id)
      end

      def send_action(context, id, action) do
        Entities.Entity.send_action(__MODULE__, context, id, action)
      end

      @doc false
      def handle_create(context, args) do
        raise "handle_create/2 not implemented"
      end

      @doc false
      def handle_action(_state, _action) do
        raise "handle_action/2 not implemented"
      end

      @doc false
      def apply_event(_state, _event) do
        raise "apply_event/2 not implemented"
      end

      defoverridable handle_action: 2, apply_event: 2, handle_create: 2
    end
  end

  def create(module, context, args) do
    {:ok, result} =
      Repo.transaction(fn ->
        entity =
          %EntityRow{
            version: 0,
            type: module.get_entity_type()
          }
          |> Repo.insert!()

        action = module.handle_create(context, entity.id, args)

        send_action(module, context, entity.id, action)
      end)

    result
  end

  def send_action(module, context, id, action) do
    {:ok, result} =
      Repo.transaction(fn ->
        snapshot = get(module, context, id)

        current_version = get_version(snapshot)

        event = module.handle_action(snapshot, action)

        action_row = persist_action(module, context, id, action)

        persist_event(module, action_row, event, current_version + 1)

        update_entity_version(id, current_version, current_version + 1)

        _apply_event(module, snapshot, event)
      end)

    result
  end

  defp get_version(entity) do
    cond do
      is_nil(entity) -> 0
      true -> entity.version
    end
  end

  defp persist_action(module, context, entity_id, action) when is_integer(entity_id) do
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

  defp persist_event(module, %ActionRow{} = action, event, entity_version)
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

  defp update_entity_version(id, expected_version, new_version)
       when is_integer(id) and is_integer(expected_version) and is_integer(new_version) do
    query =
      from e in EntityRow,
        where: e.id == ^id,
        update: [set: [version: ^new_version]]

    # TODO: check expected version.
    Repo.update_all(query, [])
  end

  def get(module, _context, id) do
    Repo.get!(EntityRow, id)

    query =
      from e in EventRow,
        where: e.entity_id == ^id,
        order_by: e.entity_version,
        select: e

    Repo.all(query)
    |> Enum.map(&event_row_to_event/1)
    |> Enum.reduce(nil, fn event, state -> _apply_event(module, state, event) end)
  end

  defp event_row_to_event(%EventRow{} = event_row) do
    module = String.to_existing_atom(event_row.type)

    # Workaround so that we have an struct (the keys are atoms) and not a map (the keys are strings)
    {:ok, payload} =
      event_row.payload
      |> Poison.encode()
      |> (fn {:ok, json} -> json end).()
      |> Poison.decode(as: struct!(module))

    payload
  end

  defp _apply_event(module, state, event) do
    state = module.apply_event(state, event)
    %{state | version: state.version + 1}
  end
end
