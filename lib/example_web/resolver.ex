defmodule Example.Schema.Resolver do
  alias Example.ShoppingList
  alias Entities.Context

  def get_shopping_list(_, args, _) do
    context = %Context{user_id: 1}
    list = ShoppingList.get(context, args.id)
    {:ok, list}
  end

  def create_shopping_list(_, args, _) do
    context = %Context{user_id: 1}
    data = ShoppingList.create(context, args)
    {:ok, data}
  end

  def change_shopping_list_name(_, %{shopping_list_id: shopping_list_id, name: name}, _) do
    context = %Context{user_id: 1}
    changed = ShoppingList.set_name(context,  %{shopping_list_id: shopping_list_id, name: name})
    {:ok, changed}
  end
end
