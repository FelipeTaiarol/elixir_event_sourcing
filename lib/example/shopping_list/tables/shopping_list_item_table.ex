defmodule Example.ShoppingList.Tables.ShoppingListItemTable do
  use Ecto.Schema
  import Ecto.Changeset
  @schema_prefix "read"

  @primary_key {:id, :string, []}
  schema "shopping_list_items" do
    field :name, :string
    field :quantity, :integer
    belongs_to :shopping_list, Example.ShoppingList.Tables.ShoppingListTable
    timestamps()
  end

  def changeset(event, attrs) do
    required_fields = [:id, :name, :shopping_list_id]
    optional_fields = [:quantity]
    event |> cast(attrs, required_fields ++ optional_fields)
  end
end
