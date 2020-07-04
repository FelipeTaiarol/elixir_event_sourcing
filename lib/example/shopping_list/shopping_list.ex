defmodule Example.ShoppingList do
  alias Example.ShoppingList.Entity
  alias Entities.Context
  alias Example.ShoppingList.Actions.{SetName}

  defstruct [
    :id,
    :name,
    :version,
    :items
  ]

  @type t :: %__MODULE__{
    id: integer,
    name: String.t(),
    version: integer,
    items: ShoppingList.ShoppingListItem.t
  }


  def create(%Context{} = context, %{name: name}) do
    Entity.create(context, %{name: name})
  end

  def get(%Context{} = context, id) when is_integer(id) do
    shopping_list_process(id, context)
      |> Entity.get(context)
  end

  def set_name(%Context{} = context, %{shopping_list_id: shopping_list_id, name: name}) do
    action = %SetName{
      id: shopping_list_id,
      name: name
    }
    shopping_list_process(shopping_list_id, context)
      |> Entity.send_action(context, action)
  end

  defp shopping_list_process(shopping_list_id, context) do
    Entities.Supervisor.entity_process(
      Example.ShoppingList.Entity,
      shopping_list_id,
      context
    )
  end
end
