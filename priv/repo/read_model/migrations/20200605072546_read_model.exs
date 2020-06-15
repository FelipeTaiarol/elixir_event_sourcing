defmodule Example.Repo.Migrations.ReadModel do
  use Ecto.Migration

  def change do
    create table(:entity_sync_state, prefix: "read", primary_key: false) do
      add(:entity_id, :string, null: false, primary_key: true)
      add(:entity_version, :integer, null: false)
    end

    create(unique_index(:entity_sync_state, [:entity_id], prefix: "read"))

    create table(:shopping_lists, prefix: "read", primary_key: false) do
      add(:id, :integer, null: false, primary_key: true)
      add(:name, :string, null: false)
      timestamps()
    end

    create(unique_index(:shopping_lists, [:name], prefix: "read"))
  end
end
