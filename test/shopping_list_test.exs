defmodule CreateShoppingListTest do
  use Example.ConnCase

  @createShoppingList """
  mutation ($name: String!) {
    createShoppingList(name: $name) {
      id,
      name,
      version
    }
  }
  """

  @changeShoppingListName """
  mutation ($shoppingListId: Int!, $name: String!){
    changeShoppingListName(shoppingListId: $shoppingListId, name: $name){
      id,
      name,
      version
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

  @addItem """
  mutation ($shoppingListId: Int!, $itemName: String!){
    addItem(shoppingListId: $shoppingListId, name: $itemName){
      id,
      version,
      items {
        name
      }
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
             "data" => %{"createShoppingList" => %{"name" => name, "id" => id, "version" => 1}}
           }

    conn =
      post(conn, "/api", %{
        "query" => @changeShoppingListName,
        "variables" => %{shoppingListId: id, name: new_name}
      })

    assert json_response(conn, 200) == %{
             "data" => %{
               "changeShoppingListName" => %{"name" => new_name, "id" => id, "version" => 2}
             }
           }

    conn =
      post(conn, "/api", %{
        "query" => @shoppingList,
        "variables" => %{id: id}
      })

    assert json_response(conn, 200) == %{
             "data" => %{"shoppingList" => %{"name" => new_name, "id" => id, "version" => 2}}
           }

    conn =
      post(conn, "/api", %{
        "query" => @addItem,
        "variables" => %{shoppingListId: id, itemName: "item 1"}
      })

    assert json_response(conn, 200) == %{
             "data" => %{
               "addItem" => %{"id" => id, "version" => 3, "items" => [%{"name" => "item 1"}]}
             }
           }
  end
end
