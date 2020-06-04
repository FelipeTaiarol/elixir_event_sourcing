defmodule Workflows.Entities.Action do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entity_actions" do
    field :type, :string
    field :payload, :map
    field :entity_id, :integer
    field :created_by, :integer

    timestamps()
  end

  def changeset(event, attrs) do
    required_fields = [:type, :payload, :entity_id, :created_by]
    optional_fields = [];
    event |> cast(attrs, required_fields ++ optional_fields)
  end
end
