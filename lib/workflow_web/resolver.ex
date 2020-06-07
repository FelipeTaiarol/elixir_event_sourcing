defmodule Workflows.Schema.Resolver do
  alias Workflows.Core.Workflow.Actions.{SetName}
  alias Workflows.Core.WorkflowEntity

  def get_workflow(_, args, _) do
    data = WorkflowEntity.get(%{user_id: 1}, args.id)
    {:ok, data}
  end

  def create_workflow(_, args, _) do
    data = WorkflowEntity.create(%{user_id: 1}, args)
    {:ok, data}
  end

  def change_workflow_name(_, args, _) do
    data =
      WorkflowEntity.send_action(%{user_id: 1}, args.workflow_id, %SetName{
        id: args.workflow_id,
        name: args.name
      })

    {:ok, data}
  end
end
