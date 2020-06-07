defmodule Workflows.Entities.Entity do
  use Ecto.Schema
  import Ecto.Changeset
  @schema_prefix "entities"

  schema "entities" do
    field :version, :integer
    field :type, :string
    timestamps()
  end

  def changeset(entity, attrs) do
    required_fields = [:version, :type]
    optional_fields = []
    entity |> cast(attrs, required_fields ++ optional_fields)
  end
end
