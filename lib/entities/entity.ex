defmodule Entities.Entity do
  import Ecto.Query
  alias Entities.Entity.{EventRow, ActionRow, EntityRow}
  alias Example.Repo
  alias Entities.Context

  @doc """
    Receives the current state of the Entity and an Action and it should return an Event
  """
  @callback handle_action(context :: any, state :: any, action :: any) :: any
  @doc """
    Receives the current state of the Entity and an Event and it should return the changed Entity state.
  """
  @callback apply_event(context :: any, state :: any, event :: any) :: any
  @doc """
    Returns the Entity type.
  """
  @callback get_entity_type() :: String.t()
  @doc """
    It should return the action that creates this Entity.
    The Action will also be sent to handle_action/3
  """
  @callback handle_create(context :: any, id :: Integer.t(), args :: any) :: any
  @doc """
    Receives the current state of the Entity and an Event and it can project that event to a data store.
  """
  @callback project_event(context :: any, state :: any, event :: any) :: any

  defmacro __using__([]) do
    quote do
      @behaviour Entities.Entity
      use GenServer

      def start_link({entity_id, context}) do
        IO.puts("Starting Entity #{inspect(__MODULE__)} #{entity_id} #{inspect(context)}")
        GenServer.start_link(__MODULE__, {entity_id, context}, name: via_tuple(entity_id))
      end

      @impl GenServer
      def init({entity_id, context}) do
        state = Entities.Entity.get(__MODULE__, context, entity_id)
        {:ok, state}
      end

      defp via_tuple(entity_id) do
        Entities.EntityRegistry.via_tuple({__MODULE__, entity_id})
      end

      def create(context, args) do
        Entities.Entity.create(__MODULE__, context, args)
      end

      def get(entity, context) when is_pid(entity) do
        GenServer.call(entity, {:get, context})
      end

      def send_action(entity, context, action) when is_pid(entity) do
        GenServer.call(entity, {:send_action, context, action})
      end

      @impl GenServer
      def handle_call({:get, context}, _from, %{} = state) do
        {:reply, state, state}
      end

      @impl GenServer
      def handle_call(
            {:send_action, context, action},
            _from,
            %{} = state
          ) do
        state = Entities.Entity.send_action(__MODULE__, context, state.id, state, action)
        {:reply, state, state}
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

      @doc false
      def project_event(%Context{} = _context, _state, _event) do
      end

      defoverridable handle_action: 2, apply_event: 2, handle_create: 2, project_event: 3
    end
  end

  def create(module, %Context{} = context, args) do
    {:ok, result} =
      Repo.transaction(fn ->
        entity =
          %EntityRow{
            version: 0,
            type: module.get_entity_type()
          }
          |> Repo.insert!()

        create_action = module.handle_create(context, entity.id, args)

        send_action(module, context, entity.id, nil, create_action)
      end)

    result
  end

  def send_action(module, %Context{} = context, id, state, action) when is_integer(id) do
    {:ok, result} =
      Repo.transaction(fn ->
        current_version = get_version(state)

        event = module.handle_action(context, state, action)

        action_row = persist_action(module, context, id, action)

        persist_event(module, action_row, event, current_version + 1)

        update_entity_version(id, current_version, current_version + 1)

        final_state = _apply_event(module, context, state, event)

        module.project_event(context, state, event)

        final_state
      end)

    result
  end

  defp get_version(entity) do
    cond do
      is_nil(entity) -> 0
      true -> entity.version
    end
  end

  defp persist_action(module, %Context{} = context, entity_id, action)
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
    get_state(module, nil, id)
  end

  def get_state(module, state, id) do
    version = get_version(state)

    query =
      from e in EventRow,
        where:
          e.entity_id == ^id and
            e.entity_version > ^version,
        order_by: e.entity_version,
        select: e

    events = Repo.all(query)
    play_events(module, events, nil)
  end

  defp play_events(module, events, state) do
    events
    |> Enum.map(&row_to_event_and_context/1)
    |> Enum.reduce(state, fn {event, context}, state ->
      _apply_event(module, context, state, event)
    end)
  end

  defp row_to_event_and_context(%EventRow{} = row) do
    module = String.to_existing_atom(row.type)

    # Workaround so that we have an struct (the keys are atoms) and not a map (the keys are strings)
    {:ok, event} =
      row.payload
      |> Poison.encode()
      |> (fn {:ok, json} -> json end).()
      |> Poison.decode(as: struct!(module))

    {event, %Context{user_id: row.created_by}}
  end

  defp _apply_event(module, %Context{} = context, state, event) do
    state = module.apply_event(context, state, event)
    %{state | version: state.version + 1}
  end
end
