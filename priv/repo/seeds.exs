alias Example.ShoppingList
alias Example.ShoppingList.Actions.SetName

context = %{
  user_id: 1
}

shopping_list = ShoppingList.create(%{user_id: 1}, %{name: "shopping_list 1"})
ShoppingList.send_action(context, shopping_list.id, %SetName{name: "new name"})
