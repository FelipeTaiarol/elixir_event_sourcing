defmodule Example.ShoppingList.CreateShoppingList do
  alias Entities.Context
  alias Example.ShoppingList.Actions.CreateShoppingList
  alias Example.ShoppingList.Events.ShoppingListCreated
  alias Example.ShoppingListEntity

  def handle_action(%Context{} = _context, state, %CreateShoppingList{id: id, name: name}) do
    cond do
      is_nil(state) ->
        %ShoppingListCreated{
          id: id,
          name: name
        }

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
        %ShoppingListEntity{} = _state,
        %ShoppingListCreated{} = event
      ) do
    IO.puts("PROJECT #{inspect(event)}")
  end
end
