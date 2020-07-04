defmodule Example.ShoppingList.SetName do
  alias Entities.Context
  alias Example.ShoppingList.Actions.SetName
  alias Example.ShoppingList.Events.NameChanged
  alias Example.ShoppingList.Entity
  alias Example.ShoppingList
  alias Example.Repo

  def handle_action(%Context{} = _context, %ShoppingList.Entity{} = _state, %SetName{name: name}) do
    [%NameChanged{name: name}]
  end

  def apply_event(%Context{} = _context, %ShoppingList.Entity{} = state, %NameChanged{name: name}) do
    %ShoppingList.Entity{state | name: name}
  end

  def project_event(
        %Context{} = _context,
        %ShoppingList.Entity{} = _before_event,
        %NameChanged{} = _event,
        %ShoppingList.Entity{} = after_event
      ) do
    %ShoppingList.ShoppingListTable{id: after_event.id}
    |> ShoppingList.ShoppingListTable.changeset(%{id: after_event.id, name: after_event.name})
    |> Repo.update!()
  end
end
