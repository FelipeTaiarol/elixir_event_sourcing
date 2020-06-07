defmodule Workflows.ReadModel.Workflow do
  use Ecto.Schema
  import Ecto.Changeset
  @schema_prefix "read"

  schema "workflows" do
    field :name, :string
    timestamps()
  end

  def changeset(event, attrs) do
    required_fields = [:name]
    optional_fields = [];
    event |> cast(attrs, required_fields ++ optional_fields)
  end

  # def handle_event(%Workflow{} = workflow, %Event{type: "workflow_created"} = event) do
  #   %Workflow{

  #   }
  # end
end
