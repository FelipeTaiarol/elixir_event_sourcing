defmodule Example.ReadModel.ShoppingList do
  use Ecto.Schema
  import Ecto.Changeset
  @schema_prefix "read"

  schema "shopping_lists" do
    field :name, :string
    timestamps()
  end

  def changeset(event, attrs) do
    required_fields = [:name]
    optional_fields = []
    event |> cast(attrs, required_fields ++ optional_fields)
  end
end