defmodule GenericCode do
  @callback handle_action(state :: any, action :: any) :: any

  defmacro __using__(_) do
    quote do
      @behaviour GenericCode

      def send_action(text) do
        GenericCode.send_action(__MODULE__, text)
      end

      def handle_action(_state, _action) do
        raise "handle_action/2 not implemented"
      end

      defoverridable handle_action: 2
    end
  end

  def send_action(module, text) do
    # Do generic stuff
    IO.puts "type: #{module.type}"
    module.handle_action(nil, text)
  end
end
