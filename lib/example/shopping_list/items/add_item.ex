defmodule Example.ShoppingList.Items.AddItem do
  alias Entities.Context
  alias Example.ShoppingList.Actions.AddItem
  alias Example.ShoppingList.Events.ItemAdded
  alias Example.ShoppingList
  alias Example.Repo

  def handle_action(%Context{} = _context, %ShoppingList{} = _state, %AddItem{id: id, name: name, quantity: quantity}) do
    [%ItemAdded{id: id, name: name, quantity: quantity}]
  end

  def apply_event(%Context{} = _context, %ShoppingList{} = state, %ItemAdded{id: id, name: name, quantity: quantity}) do
    new_item = %ShoppingList.ShoppingListTableItemTable{id: id, name: name, quantity: quantity}
    items = state.items ++ [new_item]
    %ShoppingList{state | items: items}
  end

  def project_event(
        %Context{} = _context,
        %ShoppingList{} = _before_event,
        %ItemAdded{} = _event,
        %ShoppingList{} = after_event
      ) do
   #TODO
  end
end
