defmodule Example.ShoppingList.ShoppingListTableItemTable do
  use Ecto.Schema
  import Ecto.Changeset
  @schema_prefix "read"

  schema "shopping_list_items" do
    field :name, :string
    field :quantity, :integer
    belongs_to :shopping_list, Example.ShoppingList.ShoppingListTable
    timestamps()
  end

  def changeset(event, attrs) do
    required_fields = [:id, :name]
    optional_fields = [:quantity]
    event |> cast(attrs, required_fields ++ optional_fields)
  end
end
