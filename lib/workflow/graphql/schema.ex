defmodule Workflows.Schema do
  use Absinthe.Schema
  alias Workflows.Core.Workflow
  alias Workflows.Core.Workflow.ActionRows.{SetName}

  query do
    @desc "Get Workflow"
    field :workflow, :workflow do
      arg(:id, non_null(:integer))

      resolve(fn _, args, _ ->
        data = Workflow.get(%{user_id: 1}, args.id)
        {:ok, data}
      end)
    end

    # @desc "Get EntityRow EventRows"
    # field :events, list_of(:event) do
    #   resolve &Workflows.Entities.Resolver.get_events/3
    # end
  end

  mutation do
    @desc "Create a Workflow"
    field :create_workflow, :integer do
      arg(:name, non_null(:string))

      resolve(fn _, args, _ ->
        data = Workflow.create(%{user_id: 1}, args)
        {:ok, data}
      end)
    end

    @desc "Change Workflow name"
    field :change_workflow_name, :workflow do
      arg(:workflow_id, non_null(:integer))
      arg(:name, non_null(:string))

      resolve(fn _, args, _ ->
        data =
          Workflow.send_action(%{user_id: 1}, args.workflow_id, %SetName{
            id: args.workflow_id,
            name: args.name
          })

        IO.puts(inspect(data))
        {:ok, data}
      end)
    end
  end

  object :entity do
    field :id, non_null(:integer)
    field :version, non_null(:integer)
  end

  object :event do
    field :type, non_null(:string)
    field :payload, non_null(:string)
    field :entity_id, non_null(:string)
    field :entity_version, non_null(:integer)
  end

  object :workflow do
    field :id, non_null(:integer)
    field :name, non_null(:string)
  end

  input_object :add_task do
    field :type, non_null(:string)
    field :payload, :add_task_payload
  end

  input_object :add_task_payload do
    field :id, non_null(:string)
    field :description, :string
  end
end
