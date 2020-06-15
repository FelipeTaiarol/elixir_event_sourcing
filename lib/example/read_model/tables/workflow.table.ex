defmodule Example.ReadModel.Workflow do
  use Ecto.Schema
  import Ecto.Changeset
  @schema_prefix "read"

  schema "workflows" do
    field :name, :string
    timestamps()
  end

  def changeset(event, attrs) do
    required_fields = [:name]
    optional_fields = []
    event |> cast(attrs, required_fields ++ optional_fields)
  end
end
