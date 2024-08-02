defmodule WebmentionsDb.Repo.Migrations.AddColumnLatestMentionForTableTarget do
  use Ecto.Migration

  def change do
    alter table(:targets) do
      add :latest_mention, :utc_datetime
    end
  end
end
