defmodule Example.Schema.Resolver do
  alias Example.Core.Workflow.Actions.{SetName}
  alias Example.Core.WorkflowEntity
  alias Entities.Context

  def get_shopping_list(_, args, _) do
    entity =
      Entities.Supervisor.entity_process(Example.Core.WorkflowEntity, args.id, %Context{
        user_id: 1
      })

    data = WorkflowEntity.get(entity, %Context{user_id: 1})
    {:ok, data}
  end

  def create_shopping_list(_, args, _) do
    data = WorkflowEntity.create(%Context{user_id: 1}, args)
    {:ok, data}
  end

  def change_shopping_list_name(_, %{shopping_list_id: shopping_list_id, name: name}, _) do
    entity =
      Entities.Supervisor.entity_process(Example.Core.WorkflowEntity, shopping_list_id, %Context{
        user_id: 1
      })

    data =
      WorkflowEntity.send_action(entity, %Context{user_id: 1}, %SetName{
        id: shopping_list_id,
        name: name
      })

    {:ok, data}
  end
end
