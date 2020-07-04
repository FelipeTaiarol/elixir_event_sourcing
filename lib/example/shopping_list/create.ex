defmodule Example.ShoppingList.CreateShoppingList do
  alias Entities.Context
  alias Example.ShoppingList.Actions.CreateShoppingList
  alias Example.ShoppingList.Events.ShoppingListCreated
  alias Example.ShoppingList
  alias Example.ShoppingList.Tables
  alias Example.Repo

  def handle_action(%Context{} = _context, state, %CreateShoppingList{id: id, name: name}) do
    cond do
      is_nil(state) ->
        [
          %ShoppingListCreated{
            id: id,
            name: name
          }
        ]

      true ->
        raise "There is already a shopping_list with id #{id}"
    end
  end

  def apply_event(%Context{} = _context, nil, %ShoppingListCreated{} = event) do
    %ShoppingList{
      id: event.id,
      name: event.name,
      version: 0,
      items: []
    }
  end

  def project_event(
        %Context{} = _context,
        _before_event,
        %ShoppingListCreated{} = _event,
        %ShoppingList{} = after_event
      ) do
    %Tables.ShoppingListTable{}
    |> Tables.ShoppingListTable.changeset(%{id: after_event.id, name: after_event.name})
    |> Repo.insert!()
  end
end
