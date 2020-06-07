defmodule Workflows.Schema do
  use Absinthe.Schema
  alias Workflows.Schema.Resolver
  alias Workflows.Core.Workflow.Actions.{SetName}
  alias Workflows.Core.WorkflowEntity

  query do
    @desc "Get Workflow"
    field :workflow, :workflow do
      arg(:id, non_null(:integer))
      resolve(&Resolver.get_workflow/3)
    end
  end

  mutation do
    @desc "Create a Workflow"
    field :create_workflow, :workflow do
      arg(:name, non_null(:string))
      resolve(&Resolver.create_workflow/3)
    end

    @desc "Change Workflow name"
    field :change_workflow_name, :workflow do
      arg(:workflow_id, non_null(:integer))
      arg(:name, non_null(:string))
      resolve(&Resolver.change_workflow_name/3)
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
    field :version, non_null(:integer)
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
