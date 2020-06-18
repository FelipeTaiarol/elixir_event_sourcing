defmodule Example.Repo.Migrations.Entities do
  use Ecto.Migration

  def change do
    create table(:entities, prefix: "entities") do
      add(:version, :bigint, null: false)
      add(:type, :string, null: false)
      timestamps()
    end

    create(constraint("entities", :version_must_be_positive, check: "version >= 0", prefix: "entities"))

    create table(:entity_actions, prefix: "entities") do
      add(:entity_id, references(:entities), null: false)
      add(:entity_type, :string, null: false)
      add(:type, :string, null: false)
      add(:payload, :map, null: false)
      add(:created_by, :bigint, null: false)
      timestamps()
    end

    create table(:entity_events, prefix: "entities") do
      add(:entity_id, references(:entities), null: false)
      add(:entity_type, :string, null: false)
      add(:entity_version, :bigint, null: false)
      add(:type, :string, null: false)
      add(:payload, :map, null: false)
      add(:created_by, :bigint, null: false)
      add(:action_id, references(:entity_actions), null: false)
      timestamps()
    end

    create(unique_index(:entity_events, [:entity_id, :entity_version], prefix: "entities"))
  end
end
