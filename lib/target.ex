defmodule Target do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "targets" do
    # same as wm-target in mention
    field(:url, :string)
    # the file name that generate script should put things to
    field(:output_file, :string)

    field(:latest_mention, :utc_datetime)

    many_to_many(:mentions, Mention, join_through: "target_mentions")
  end

  def changeset(%Target{} = target, changes) do
    target
    |> cast(changes, [
      :url,
      :output_file,
      :latest_mention
    ])
    |> validate_required([
      :url,
      :output_file
    ])
    |> unique_constraint([:url, :output_file])
  end

  # we will not create target with repeated URL
  def create_target(url, mention_id) do
    query =
      from(u in Target,
        where: u.url == ^url,
        select: u.id
      )

    case WebmentionsDb.Repo.one(query) do
      nil ->
        %Target{}
        |> Target.changeset(%{
          url: url,
          output_file: get_output(url)
        })
        |> WebmentionsDb.Repo.insert()

        target_id = WebmentionsDb.Repo.one(query)
        insert(target_id, mention_id)

      target_id ->
        insert(target_id, mention_id)
    end
  end

  # only record non-exist mention
  defp insert(target_id, mention_id) do
    query =
      from(k in TargetMentions,
        where: k.target_id == ^target_id and k.mention_id == ^mention_id,
        select: k.id
      )

    case WebmentionsDb.Repo.one(query) do
      nil ->
        %TargetMentions{target_id: target_id, mention_id: mention_id}
        |> WebmentionsDb.Repo.insert(on_conflict: :raise)

      _ ->
        nil
    end
  end

  def list_all() do
    query = from(t in Target)

    WebmentionsDb.Repo.all(query)
    |> WebmentionsDb.Repo.preload(
      :mentions,
      order_by: [desc: :wm_received]
    )
  end

  defp get_output(url) do
    uri = URI.parse(url)
    base = uri.path |> Path.basename(".xml")
    prefix = Application.fetch_env!(:webmentions_db, :prefix)
    extension = Application.fetch_env!(:webmentions_db, :extension)

    "#{prefix}#{base}.#{extension}"
  end
end
