defmodule Example.Core.ShoppingList.SetName do
  alias Entities.Context
  alias Example.Core.ShoppingList.Actions.SetName
  alias Example.Core.ShoppingList.Events.NameChanged
  alias Example.Core.ShoppingListEntity

  def handle_action(%Context{} = _context, %ShoppingListEntity{} = _state, %SetName{name: name}) do
    %NameChanged{name: name}
  end

  def apply_event(%Context{} = _context, %ShoppingListEntity{} = state, %NameChanged{
        name: name
      }) do
    %ShoppingListEntity{state | name: name}
  end

  def project_event(
        %Context{} = _context,
        %ShoppingListEntity{} = _state,
        %NameChanged{} = event
      ) do
    IO.puts("PROJECT #{inspect(event)}")
  end
end
