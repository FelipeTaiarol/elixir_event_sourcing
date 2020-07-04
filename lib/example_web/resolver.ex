defmodule Example.Schema.Resolver do
  alias Example.ShoppingList.Actions.{SetName}
  alias Example.ShoppingListEntity
  alias Entities.Context

  def get_shopping_list(_, args, _) do
    context = %Context{user_id: 1}

    data =
      shopping_list_process(args.id, context)
      |> ShoppingListEntity.get(context)

    {:ok, data}
  end

  def create_shopping_list(_, args, _) do
    context = %Context{user_id: 1}
    data = ShoppingListEntity.create(context, args)
    {:ok, data}
  end

  def change_shopping_list_name(_, %{shopping_list_id: shopping_list_id, name: name}, _) do
    context = %Context{user_id: 1}

    action = %SetName{
      id: shopping_list_id,
      name: name
    }

    data =
      shopping_list_process(shopping_list_id, context)
      |> ShoppingListEntity.send_action(context, action)

    {:ok, data}
  end

  defp shopping_list_process(shopping_list_id, context) do
    Entities.Supervisor.entity_process(
      Example.ShoppingListEntity,
      shopping_list_id,
      context
    )
  end
end
