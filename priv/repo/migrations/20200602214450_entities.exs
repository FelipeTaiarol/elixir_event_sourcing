defmodule Workflows.Repo.Migrations.Entities do
  use Ecto.Migration

  def change do
    create table(:entities) do
      add :version, :bigint, null: false
      timestamps()
    end

    create table(:entity_actions) do
      add :entity_id, references(:entities), null: false
      add :type, :string, null: false
      add :payload, :map, null: false
      add :created_by, :bigint, null: false
      timestamps()
    end

    create table(:entity_events) do
      add :entity_id, references(:entities), null: false
      add :entity_version, :bigint, null: false
      add :type, :string, null: false
      add :payload, :map, null: false
      add :created_by, :bigint, null: false
      add :action_id, references(:entity_actions), null: false
      timestamps()
    end

    create unique_index(:entity_events, [:entity_id, :entity_version])
  end
end
