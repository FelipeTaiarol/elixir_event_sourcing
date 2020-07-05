defmodule Example.Schema.Resolver do
  alias Example.ShoppingList
  alias Entities.Context

  @spec get_shopping_list(any, any, any) :: {:ok, ShoppingList.t()}
  def get_shopping_list(_, args, _) do
    context = %Context{user_id: 1}
    list = ShoppingList.get(context, args.id)
    {:ok, list}
  end

  @spec create_shopping_list(any, any, any) :: {:ok, ShoppingList.t()}
  def create_shopping_list(_, args, _) do
    context = %Context{user_id: 1}
    created = ShoppingList.create(context, args)
    {:ok, created}
  end

  @spec change_shopping_list_name(any, any, any) :: {:ok, ShoppingList.t()}
  def change_shopping_list_name(_, %{shopping_list_id: shopping_list_id, name: name}, _) do
    context = %Context{user_id: 1}
    changed = ShoppingList.set_name(context, shopping_list_id, name)
    {:ok, changed}
  end

  @spec add_item(any, any, any) :: {:ok, ShoppingList.t()}
  def add_item(_, args, _) do
    context = %Context{user_id: 1}
    changed = ShoppingList.add_item(context, args.shopping_list_id, args)
    {:ok, changed}
  end
end
