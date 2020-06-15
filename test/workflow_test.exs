defmodule CreateShoppingListTest do
  use Example.ConnCase

  @createShoppingList """
  mutation ($name: String!) {
    createShoppingList(name: $name) {
      id,
      name
    }
  }
  """

  @changeShoppingListName """
  mutation ($shoppingListId: Int!, $name: String!){
    changeShoppingListName(shoppingListId: $shoppingListId, name: $name){
      id,
      name
    }
  }
  """

  @shoppingList """
  query ($id: Int!){
    shoppingList(id: $id){
      id,
      name,
      version
    }
  }
  """

  test "workflows test", %{conn: conn} do
    conn =
      post(conn, "/api", %{
        "query" => @createShoppingList,
        "variables" => %{name: "wf1"}
      })

    assert json_response(conn, 200) == %{
             "data" => %{"createShoppingList" => %{"name" => "wf1", "id" => 1}}
           }

    conn =
      post(conn, "/api", %{
        "query" => @changeShoppingListName,
        "variables" => %{shoppingListId: 1, name: "new_name"}
      })

    assert json_response(conn, 200) == %{
             "data" => %{"changeShoppingListName" => %{"name" => "new_name", "id" => 1}}
           }

    conn =
      post(conn, "/api", %{
        "query" => @shoppingList,
        "variables" => %{id: 1}
      })

    assert json_response(conn, 200) == %{
             "data" => %{"shoppingList" => %{"name" => "new_name", "id" => 1, "version" => 2}}
           }
  end
end
