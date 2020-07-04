defmodule Example.ShoppingList.Entity do
  use Entities.Entity
  alias Entities.Context
  alias Example.ShoppingList.Actions
  alias Example.ShoppingList.Events
  alias Example.ShoppingList.CreateShoppingList
  alias Example.ShoppingList.SetName
  alias Example.ShoppingList.Items.AddItem
  alias Example.ShoppingList

  @impl true
  def get_entity_type(), do: "shopping_list"

  @impl true
  def get_entity_struct(), do: ShoppingList.__struct__()

  @impl true
  def handle_create(%Context{} = _context, id, %{name: name}) do
    %Actions.CreateShoppingList{
      id: id,
      name: name
    }
  end

  @impl true
  def handle_action(%Context{} = context, %ShoppingList{} = state, %Actions.SetName{} = event),
    do: SetName.handle_action(context, state, event)

  @impl true
  def handle_action(%Context{} = context, state, %Actions.CreateShoppingList{} = action),
    do: CreateShoppingList.handle_action(context, state, action)

  @impl true
  def handle_action(%Context{} = context, state, %Actions.AddItem{} = action),
    do: AddItem.handle_action(context, state, action)

  @impl true
  def apply_event(%Context{} = context, nil, %Events.ShoppingListCreated{} = event),
    do: CreateShoppingList.apply_event(context, nil, event)

  @impl true
  def apply_event(%Context{} = context, %ShoppingList{} = state, %Events.NameChanged{} = event),
    do: SetName.apply_event(context, state, event)

  @impl true
  def apply_event(%Context{} = context, %ShoppingList{} = state, %Events.ItemAdded{} = event),
    do: AddItem.apply_event(context, state, event)

  @impl true
  def project_event(
        %Context{} = context,
        before_event,
        %Events.ShoppingListCreated{} = event,
        %ShoppingList{} = after_event
      ),
      do: CreateShoppingList.project_event(context, before_event, event, after_event)

  @impl true
  def project_event(
        %Context{} = context,
        %ShoppingList{} = before_event,
        %Events.NameChanged{} = event,
        %ShoppingList{} = after_event
      ),
      do: SetName.project_event(context, before_event, event, after_event)

  @impl true
  def project_event(
        %Context{} = context,
        %ShoppingList{} = before_event,
        %Events.ItemAdded{} = event,
        %ShoppingList{} = after_event
      ),
      do: AddItem.project_event(context, before_event, event, after_event)
end
