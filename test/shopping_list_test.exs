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

  test "shopping_lists test", %{conn: conn} do
    create_update_read(conn, 1)
    create_update_read(conn, 2)
    create_update_read(conn, 3)
  end

  defp create_update_read(conn, id) do
    name = "list #{id}"
    new_name = "new name #{id}"

    conn =
      post(conn, "/api", %{
        "query" => @createShoppingList,
        "variables" => %{name: name}
      })

    assert json_response(conn, 200) == %{
             "data" => %{"createShoppingList" => %{"name" => name, "id" => id}}
           }

    conn =
      post(conn, "/api", %{
        "query" => @changeShoppingListName,
        "variables" => %{shoppingListId: id, name: new_name}
      })

    assert json_response(conn, 200) == %{
             "data" => %{"changeShoppingListName" => %{"name" => new_name, "id" => id}}
           }

    conn =
      post(conn, "/api", %{
        "query" => @shoppingList,
        "variables" => %{id: id}
      })

    assert json_response(conn, 200) == %{
             "data" => %{"shoppingList" => %{"name" => new_name, "id" => id, "version" => 2}}
           }
  end
end
