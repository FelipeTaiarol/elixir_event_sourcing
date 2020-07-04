defmodule Example.ShoppingList.CreateShoppingList do
  alias Entities.Context
  alias Example.ShoppingList.Actions.CreateShoppingList
  alias Example.ShoppingList.Events.ShoppingListCreated
  alias Example.ShoppingListEntity
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
    %ShoppingListEntity{
      id: event.id,
      name: event.name,
      version: 0
    }
  end

  def project_event(
        %Context{} = _context,
        _before_event,
        %ShoppingListCreated{} = _event,
        %ShoppingListEntity{} = after_event
      ) do
    %Tables.ShoppingList{}
    |> Tables.ShoppingList.changeset(%{id: after_event.id, name: after_event.name})
    |> Repo.insert!()
  end
end
