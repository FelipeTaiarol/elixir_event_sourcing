defmodule Entities.Entity do
  import Ecto.Query
  alias Entities.Entity.{EventRow, ActionRow, EntityRow}
  alias Example.Repo
  alias Entities.Context
  alias Entities.EntityHelpers

  defmodule Cache do
    defstruct [
      :last_accessed_at,
      :entity
    ]
  end

  @doc """
    Receives the current state of the Entity and an Action and it should return a list of Events
  """
  @callback handle_action(context :: any, state :: any, action :: any) :: list(any)
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
    Receives the state of the Entity before the event, the Event and the state of the Entity after the Event.
    It can project that event to a data store.
  """
  @callback project_event(context :: any, before_event :: any, event :: any, before_event :: any) :: any

  defmacro __using__([]) do
    quote do
      @behaviour Entities.Entity
      @cache_check_interval 5000 # in milliseconds
      @cache_invalidation_time 60 # in seconds

      # The process will stop itself if the Entity was not accessed in more than @cache_invalidation_time.
      # If the process crashes for another reason, the Entity Supervisor will start a new one the next time the Entity is accessed.
      use GenServer, restart: :temporary

      @doc false
      def start_link({entity_id, context}) do
        GenServer.start_link(__MODULE__, {entity_id, context}, name: via_tuple(entity_id))
      end

      @impl GenServer
      def init({entity_id, context}) do
        Process.send_after(self(), :maybe_stop_process, @cache_check_interval)
        state = %Cache{
          entity: Entities.Entity.get(__MODULE__, context, entity_id),
          last_accessed_at: DateTime.utc_now()
        }
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
      def handle_call({:get, context}, _from, %Cache{} = state) do
        new_cache = %Cache{state | last_accessed_at: DateTime.utc_now() }
        {:reply, state.entity, new_cache}
      end

      @impl GenServer
      def handle_call(
            {:send_action, context, action},
            _from,
            %Cache{} = state
          ) do
        entity = Entities.Entity.send_action(__MODULE__, context, state.entity.id, state.entity, action)
        new_cache = %Cache{state | last_accessed_at: DateTime.utc_now(), entity: entity }
        {:reply, entity, new_cache}
      end

      @impl GenServer
      def handle_info(:maybe_stop_process, %Cache{} = state) do
        Process.send_after(self(), :maybe_stop_process, @cache_check_interval)

        limit = DateTime.add(state.last_accessed_at, @cache_invalidation_time, :second)
        diff = DateTime.diff(limit, DateTime.utc_now())
        cond do
          diff < 0 -> {:stop, :normal, state}
          true -> {:noreply, state}
        end
      end

      @doc false
      def handle_create(_context, _args) do
        raise "handle_create/2 not implemented"
      end

      @doc false
      def handle_action(_context, _state, _action) do
        raise "handle_action/2 not implemented"
      end

      @doc false
      def apply_event(_context, _state, _event) do
        raise "apply_event/2 not implemented"
      end

      @doc false
      def project_event(%Context{} = _context, _before_event, _event, _after_event) do
      end

      defoverridable handle_action: 3, apply_event: 3, handle_create: 2, project_event: 4
    end
  end

  def create(module, %Context{} = context, args) do
    {:ok, result} =
      Repo.transaction(fn ->
        _create(module, context, args)
      end)
    result
  end

  defp _create(module, %Context{} = context, args) do
    entity =
      %EntityRow{
        version: 0,
        type: module.get_entity_type()
      }
      |> Repo.insert!()

    create_action = module.handle_create(context, entity.id, args)

    send_action(module, context, entity.id, nil, create_action)
  end

  def send_action(module, %Context{} = context, id, state, action) when is_integer(id) do
    {:ok, result} =
      Repo.transaction(fn ->
        _send_action(module, context, id, state, action)
      end)
    result
  end

  defp _send_action(module, %Context{} = context, id, state, action) do
    current_version = EntityHelpers.get_version(state)

    action_row = EntityHelpers.persist_action(module, context, id, action)

    events = module.handle_action(context, state, action)

    final_state = events
      |> Enum.with_index
      |> Enum.reduce(state, fn({event, index}, state) ->
        next_version = current_version + index + 1
        process_event(module, context, state, action_row, event, next_version)
      end)

      EntityHelpers.update_entity_version(id, current_version, current_version + Enum.count(events))

    final_state
  end

  defp process_event(module, %Context{} = context, state, %ActionRow{} = action_row, event, next_version) do
    EntityHelpers.persist_event(module, action_row, event, next_version)

    final_state = _apply_event(module, context, state, event)

    module.project_event(context, state, event, final_state)

    final_state
  end

  def get(module, _context, id) do
    Repo.get!(EntityRow, id)
    get_state(module, nil, id)
  end

  def get_state(module, state, id) do
    version = EntityHelpers.get_version(state)

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
    |> Enum.map(&EntityHelpers.row_to_event_and_context/1)
    |> Enum.reduce(state, fn {event, context}, state ->
      _apply_event(module, context, state, event)
    end)
  end

  defp _apply_event(module, %Context{} = context, state, event) do
    state = module.apply_event(context, state, event)
    %{state | version: state.version + 1}
  end
end
