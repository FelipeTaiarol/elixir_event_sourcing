alias Workflows.Core.Workflow
alias Workflows.Core.Workflow.ActionRows.SetName

context = %{
  user_id: 1
}

workflow = Workflow.create(%{user_id: 1}, %{name: "workflow 1"})
Workflow.send_action(context, workflow.id, %SetName{name: "new name"})
