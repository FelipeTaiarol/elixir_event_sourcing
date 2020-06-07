defmodule Workflows.ReadModel.EntitySyncState do
  use Ecto.Schema
  import Ecto.Changeset
  @schema_prefix "read"

  schema "entity_sync_state" do
    field :entity_id, :string
    field :entity_version, :integer
    timestamps()
  end

  def changeset(event, attrs) do
    required_fields = [:entity_id, :entity_version]
    optional_fields = []
    event |> cast(attrs, required_fields ++ optional_fields)
  end
end
