defmodule GenericCode do
  @callback handle_action(state :: any, action :: any) :: any

  defmacro __using__(_) do
    quote do
      @behaviour GenericCode
      use GenServer

      def start_link(entity_id) do
        IO.puts("Starting")
        GenServer.start_link(__MODULE__, entity_id, name: via_tuple(entity_id))
      end

      defp via_tuple(entity_id) do
        Test.ProcessRegistry.via_tuple({__MODULE__, entity_id})
      end

      def send_action(entity, text) do
        GenServer.call(entity, {:send_action, text})
      end

      @impl GenServer
      def init(entity_id) do
        IO.puts("Initial state is #{entity_id}")
        {:ok, entity_id}
      end

      @impl GenServer
      def handle_call({:send_action, text}, _from, state) do
        result = GenericCode.send_action(__MODULE__, text)
        {:reply, result, state}
      end

      def handle_action(_state, _action) do
        raise "handle_action/2 not implemented"
      end

      defoverridable handle_action: 2
    end
  end

  def send_action(module, text) do
    # Do generic stuff
    module.handle_action(nil, text)
  end
end
