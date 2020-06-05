defmodule Workflows.Repo.Migrations.ReadModel do
  use Ecto.Migration

  def change do
    create table(:entity_sync_state, prefix: "read") do
      add :entity_id, :string, null: false
      add :entity_version, :integer, null: false
    end
    create unique_index(:entity_sync_state, [:entity_id], prefix: "read")

    create table(:tasks, prefix: "read") do
      add :description, :string, null: false
    end
    create unique_index(:tasks, [:description], prefix: "read")

  end
end
