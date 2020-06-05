defmodule Workflows.Entities.Event do
  use Ecto.Schema
  import Ecto.Changeset
  @schema_prefix "entities"

  schema "entity_events" do
    field :type, :string
    field :payload, :map
    field :entity_id, :integer
    field :entity_version, :integer
    field :action_id, :integer
    field :created_by, :integer

    timestamps()
  end

  def changeset(event, attrs) do
    required_fields = [:type, :payload, :entity_id, :entity_version, :action_id, :created_by]
    optional_fields = [];
    event |> cast(attrs, required_fields ++ optional_fields)
  end
end
