defmodule Example.Schema do
  use Absinthe.Schema
  alias Example.Schema.Resolver

  query do
    @desc "Get a shopping list"
    field :shopping_list, :shopping_list do
      arg(:id, non_null(:integer))
      resolve(&Resolver.get_shopping_list/3)
    end
  end

  mutation do
    @desc "Create a shopping list"
    field :create_shopping_list, :shopping_list do
      arg(:name, non_null(:string))
      resolve(&Resolver.create_shopping_list/3)
    end

    @desc "Change shopping list name"
    field :change_shopping_list_name, :shopping_list do
      arg(:shopping_list_id, non_null(:integer))
      arg(:name, non_null(:string))
      resolve(&Resolver.change_shopping_list_name/3)
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

  object :shopping_list do
    field :id, non_null(:integer)
    field :name, non_null(:string)
    field :version, non_null(:integer)
  end
end
