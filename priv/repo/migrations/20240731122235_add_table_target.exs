defmodule WebmentionsDb.Repo.Migrations.AddTableTarget do
  use Ecto.Migration

  def change do
    create table(:targets)  do
      add :url, :string
      add :output_file, :string
    end

    create unique_index(:targets, [:url])
    create unique_index(:targets, [:output_file])
    create unique_index(:mentions, [:id])

    create table(:target_mentions) do
      add :target_id, references(:targets)
      add :mention_id, references(:mentions)
    end
  end
end
