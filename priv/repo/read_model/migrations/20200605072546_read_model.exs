defmodule Example.Repo.Migrations.ReadModel do
  use Ecto.Migration

  def change do
    create table(:shopping_lists, prefix: "read") do
      add(:name, :string, null: false)
      timestamps()
    end

    create(unique_index(:shopping_lists, [:name], prefix: "read"))

    create table(:shopping_list_items, prefix: "read", primary_key: false) do
      add(:id, :string, primary_key: true)
      add(:name, :string, null: false)
      add(:quantity, :integer, null: false)
      add(:shopping_list_id, references(:shopping_lists), null: false, prefix: "read")
      timestamps()
    end
  end
end
