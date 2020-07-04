defmodule Example.ShoppingList.SetName do
  alias Entities.Context
  alias Example.ShoppingList.Actions.SetName
  alias Example.ShoppingList.Events.NameChanged
  alias Example.ShoppingList
  alias Example.ShoppingList.Tables
  alias Example.Repo

  def handle_action(%Context{} = _context, %ShoppingList{} = _state, %SetName{name: name}) do
    [%NameChanged{name: name}]
  end

  def apply_event(%Context{} = _context, %ShoppingList{} = state, %NameChanged{name: name}) do
    %ShoppingList{state | name: name}
  end

  def project_event(
        %Context{} = _context,
        %ShoppingList{} = _before_event,
        %NameChanged{} = _event,
        %ShoppingList{} = after_event
      ) do
    %Tables.ShoppingListTable{id: after_event.id}
    |> Tables.ShoppingListTable.changeset(%{id: after_event.id, name: after_event.name})
    |> Repo.update!()
  end
end
