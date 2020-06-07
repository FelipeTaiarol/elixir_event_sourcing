defmodule Workflows.Entities.Action do
  use Ecto.Schema
  import Ecto.Changeset
  @schema_prefix "entities"

  @type t :: %__MODULE__{
    entity_type: String.t()
  }

  schema "entity_actions" do
    field :entity_id, :integer
    field :entity_type, :string
    field :type, :string
    field :payload, :map
    field :created_by, :integer

    timestamps()
  end

  def changeset(event, attrs) do
    attrs = %{attrs | type: to_string(attrs.type), payload: Map.from_struct(attrs.payload)}
    required_fields = [:type, :payload, :entity_id, :created_by, :entity_type]
    optional_fields = [];
    event |> cast(attrs, required_fields ++ optional_fields)
  end
end
