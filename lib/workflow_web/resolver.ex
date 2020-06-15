defmodule Workflows.Schema.Resolver do
  alias Workflows.Core.Workflow.Actions.{SetName}
  alias Workflows.Core.WorkflowEntity

  def get_workflow(_, args, _) do
    entity = Entities.Supervisor.entity_process(args.id, %{user_id: 1})
    data = WorkflowEntity.get(entity, %{user_id: 1})
    {:ok, data}
  end

  def create_workflow(_, args, _) do
    data = WorkflowEntity.create(%{user_id: 1}, args)
    {:ok, data}
  end

  def change_workflow_name(_, %{workflow_id: workflow_id, name: name}, _) do
    entity = Entities.Supervisor.entity_process(workflow_id, %{user_id: 1})

    data =
      WorkflowEntity.send_action(entity, %{user_id: 1}, %SetName{
        id: workflow_id,
        name: name
      })

    {:ok, data}
  end
end
