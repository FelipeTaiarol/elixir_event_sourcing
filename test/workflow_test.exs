defmodule CreateWorkflowTest do
  use Workflows.ConnCase

  @createWorkflow """
  mutation ($name: String!) {
    createWorkflow(name: $name) {
      id,
      name
    }
  }
  """

  @changeWorkflowName """
  mutation ($workflowId: Int!, $name: String!){
    changeWorkflowName(workflowId: $workflowId, name: $name){
      id,
      name
    }
  }
  """

  @workflow """
  query ($id: Int!){
    workflow(id: $id){
      id,
      name,
      version
    }
  }
  """

  test "createWorkflow mutation creates a workflow", %{conn: conn} do
    conn =
      post(conn, "/api", %{
        "query" => @createWorkflow,
        "variables" => %{name: "wf1"}
      })

    assert json_response(conn, 200) == %{
      "data" => %{"createWorkflow" => %{"name" => "wf1", "id" => 1}}
    }

    conn =
      post(conn, "/api", %{
        "query" => @changeWorkflowName,
        "variables" => %{workflowId: 1, name: "new_name"}
      })

    assert json_response(conn, 200) == %{
      "data" => %{"changeWorkflowName" => %{"name" => "new_name", "id" => 1}}
    }

    conn =
      post(conn, "/api", %{
        "query" => @workflow,
        "variables" => %{id: 1}
      })

    assert json_response(conn, 200) == %{
      "data" => %{"workflow" => %{"name" => "new_name", "id" => 1, "version" => 2}}
    }
  end
end
