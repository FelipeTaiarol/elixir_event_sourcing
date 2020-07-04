defmodule Entities.Entity.EntityRow do
  use Ecto.Schema
  import Ecto.Changeset
  @schema_prefix "entities"

  schema "entities" do
    field :version, :integer
    field :type, :string
    field :snapshot, :map
    field :snapshot_version, :integer
    timestamps()
  end

  def changeset(entity, attrs) do
    attrs = %{attrs | snapshot: Map.from_struct(attrs.snapshot)}

    required_fields = [:snapshot, :snapshot_version]
    optional_fields = [:version, :type]
    entity |> cast(attrs, required_fields ++ optional_fields)
  end
end
