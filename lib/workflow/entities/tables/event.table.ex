defmodule Workflows.Entities.Event do
  use Ecto.Schema
  import Ecto.Changeset
  @schema_prefix "entities"

  schema "entity_events" do
    field :entity_id, :integer
    field :entity_type, :string
    field :entity_version, :integer
    field :type, :string
    field :payload, :map
    field :created_by, :integer
    field :action_id, :integer

    timestamps()
  end

  def changeset(event, attrs) do
    attrs = %{attrs | type: to_string(attrs.type), payload: Map.from_struct(attrs.payload)}

    required_fields = [
      :type,
      :payload,
      :entity_id,
      :entity_version,
      :action_id,
      :created_by,
      :entity_type
    ]

    optional_fields = []
    event |> cast(attrs, required_fields ++ optional_fields)
  end
end
