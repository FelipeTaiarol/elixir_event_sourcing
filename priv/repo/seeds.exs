alias Example.Core.ShoppingList
alias Example.Core.ShoppingList.Actions.SetName

context = %{
  user_id: 1
}

workflow = Workflow.create(%{user_id: 1}, %{name: "workflow 1"})
Workflow.send_action(context, workflow.id, %SetName{name: "new name"})
