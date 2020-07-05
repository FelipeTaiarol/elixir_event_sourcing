defmodule Example.ShoppingList do
  alias Example.ShoppingList
  alias Example.ShoppingList.Entity
  alias Entities.Context
  alias Example.ShoppingList.Actions.{SetName, AddItem}

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
          items: list(ShoppingList.t())
        }

  @spec create(Context.t(), any) :: ShoppingList.t()
  def create(%Context{} = context, %{name: name}) do
    Entity.create(context, %{name: name})
  end

  @spec get(Context.t(), integer) :: ShoppingList.t()
  def get(%Context{} = context, id) when is_integer(id) do
    shopping_list_process(id, context)
    |> Entity.get(context)
  end

  @spec set_name(Context.t(), integer, String.t()) :: ShoppingList.t()
  def set_name(%Context{} = context, shopping_list_id, name)
      when is_integer(shopping_list_id) and is_binary(name) do
    %SetName{
      id: shopping_list_id,
      name: name
    }
    |> send_action(context, shopping_list_id)
  end

  @spec add_item(Context.t(), integer, any) :: ShoppingList.t()
  def add_item(%Context{} = context, shopping_list_id, args) when is_integer(shopping_list_id) do
    %AddItem{
      id: UUID.uuid1(),
      name: args.name,
      quantity: args.quantity
    }
    |> send_action(context, shopping_list_id)
  end

  defp send_action(action, %Context{} = context, shopping_list_id) do
    shopping_list_process(shopping_list_id, context)
    |> Entity.send_action(context, action)
  end

  @spec shopping_list_process(integer, Context.t()) :: pid()
  defp shopping_list_process(shopping_list_id, context) do
    Entities.Supervisor.entity_process(
      Example.ShoppingList.Entity,
      shopping_list_id,
      context
    )
  end
end
