defmodule Example.ShoppingList.SetName do
  alias Entities.Context
  alias Example.ShoppingList.Actions.SetName
  alias Example.ShoppingList.Events.NameChanged
  alias Example.ShoppingListEntity
  alias Example.ShoppingList.Tables
  alias Example.Repo

  def handle_action(%Context{} = _context, %ShoppingListEntity{} = _state, %SetName{name: name}) do
    [%NameChanged{name: name}]
  end

  def apply_event(%Context{} = _context, %ShoppingListEntity{} = state, %NameChanged{name: name}) do
    %ShoppingListEntity{state | name: name}
  end

  def project_event(
        %Context{} = _context,
        %ShoppingListEntity{} = _before_event,
        %NameChanged{} = _event,
        %ShoppingListEntity{} = after_event
      ) do
    %Tables.ShoppingList{id: after_event.id}
    |> Tables.ShoppingList.changeset(%{id: after_event.id, name: after_event.name})
    |> Repo.update!()
  end
end
