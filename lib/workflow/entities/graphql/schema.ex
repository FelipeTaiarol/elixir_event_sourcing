defmodule Workflows.Schema do
  use Absinthe.Schema

  query do
    @desc "Get Entities"
    field :entities, list_of(:entity) do
      resolve &Workflows.Entities.Resolver.get_entities/3
    end

    @desc "Get Entity Events"
    field :events, list_of(:event) do
      resolve &Workflows.Entities.Resolver.get_events/3
    end
  end

  mutation do
    @desc "Send an action"

    field :send_action, :integer do
      arg :action, non_null(:add_task)
      resolve fn (_, args, _) -> Workflows.Entities.Resolver.save_action(args.action) end
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

  input_object :add_task do
    field :entity_id, non_null(:integer)
    field :type, non_null(:string)
    field :payload, :add_task_payload
  end

  input_object :add_task_payload do
    field :id, non_null(:string)
    field :description, :string
  end
end
