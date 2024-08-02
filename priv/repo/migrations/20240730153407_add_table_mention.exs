defmodule WebmentionsDb.Repo.Migrations.AddTableMention do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :url, :string, primary_key: true
      add :name, :string
      add :photo, :string
    end

    create table(:mentions) do
      add :author_id, :integer
      add :url, :string
      add :wm_received, :utc_datetime
      add :wm_id, :integer, primary_key: true
      add :wm_target, :string
      add :content, :string
      add :content_html, :string
      add :wm_property, :string
      add :wm_private, :boolean
    end

    create index("authors", :url)
    create index("mentions", :wm_id)
  end
end
