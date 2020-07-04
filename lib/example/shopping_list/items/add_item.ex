defmodule Example.ShoppingList.Items.AddItem do
  alias Entities.Context
  alias Example.ShoppingList.Actions.AddItem
  alias Example.ShoppingList.Events.ItemAdded
  alias Example.ShoppingList
  alias Example.ShoppingList.Tables
  alias ShoppingList.Items.Item
  alias Example.Repo

  def handle_action(%Context{} = _context, %ShoppingList{} = _state, %AddItem{
        id: id,
        name: name,
        quantity: quantity
      }) do
    [%ItemAdded{id: id, name: name, quantity: quantity}]
  end

  def apply_event(%Context{} = _context, %ShoppingList{} = state, %ItemAdded{
        id: id,
        name: name,
        quantity: quantity
      }) do
    new_item = %Item{id: id, name: name, quantity: quantity}
    items = state.items ++ [new_item]
    %ShoppingList{state | items: items}
  end

  def project_event(
        %Context{} = _context,
        %ShoppingList{} = _before_event,
        %ItemAdded{} = event,
        %ShoppingList{} = after_event
      ) do
    %Tables.ShoppingListItemTable{}
    |> Tables.ShoppingListItemTable.changeset(%{
      id: event.id,
      name: event.name,
      quantity: event.quantity,
      shopping_list_id: after_event.id
    })
    |> Repo.insert!()
  end
end
