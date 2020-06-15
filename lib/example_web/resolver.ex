defmodule Example.Schema.Resolver do
  alias Example.ShoppingList.Actions.{SetName}
  alias Example.ShoppingListEntity
  alias Entities.Context

  def get_shopping_list(_, args, _) do
    entity =
      Entities.Supervisor.entity_process(Example.ShoppingListEntity, args.id, %Context{
        user_id: 1
      })

    data = ShoppingListEntity.get(entity, %Context{user_id: 1})
    {:ok, data}
  end

  def create_shopping_list(_, args, _) do
    data = ShoppingListEntity.create(%Context{user_id: 1}, args)
    {:ok, data}
  end

  def change_shopping_list_name(_, %{shopping_list_id: shopping_list_id, name: name}, _) do
    entity =
      Entities.Supervisor.entity_process(
        Example.ShoppingListEntity,
        shopping_list_id,
        %Context{
          user_id: 1
        }
      )

    data =
      ShoppingListEntity.send_action(entity, %Context{user_id: 1}, %SetName{
        id: shopping_list_id,
        name: name
      })

    {:ok, data}
  end
end
