defmodule Example.Repo.Migrations.ReadModel do
  use Ecto.Migration

  def change do
    create table(:shopping_lists, prefix: "read", primary_key: false) do
      add(:id, :integer, null: false, primary_key: true)
      add(:name, :string, null: false)
      timestamps()
    end

    create(unique_index(:shopping_lists, [:name], prefix: "read"))
  end
end
