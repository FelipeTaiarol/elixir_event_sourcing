defmodule Workflows.Entities.Entity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entities" do
    field :version, :integer
    timestamps()
  end

  def changeset(entity, attrs) do
    required_fields = [:version]
    optional_fields = [];
    entity |> cast(attrs, required_fields ++ optional_fields)
  end
end
