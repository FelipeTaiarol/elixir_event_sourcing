defmodule Example.ShoppingList.SetName do
  alias Entities.Context
  alias Example.ShoppingList.Actions.SetName
  alias Example.ShoppingList.Events.NameChanged
  alias Example.ShoppingListEntity

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
        %ShoppingListEntity{} = _before_event,
        %NameChanged{} = _event,
        %ShoppingListEntity{} = _after_event
      ) do
  end
end
