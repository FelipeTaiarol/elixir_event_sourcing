defmodule Test do
  use GenericCode

  @impl true
  def handle_action(_state, _action) do
    IO.puts("Specific implementation")
  end
end
