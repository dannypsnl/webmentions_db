defmodule Mention do
  @moduledoc """
  This defines what a mention is
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @doc """
  Raw format of a mention

  {
    "type": "entry",
    "author": <refers to author raw format>,
    "url": <the link to view the mention>,
    "published": null,
    "wm-received": "2024-07-30T13:39:52Z",
    "wm-id": <an integer>,
    "wm-source": <the source link mention the target>,
    "wm-target": <the target link be mentioned>,
    "wm-protocol": "webmention",
    "like-of": <the target link be mentioned>,
    "wm-property": "like-of",
    "wm-private": false
  }

  Notice that, "url" may be not "wm-source", for instance bridgy will create a "wm-source", but the mention is happened at "url"

  A reply mention will have the following

  {
    ...
    "wm-protocol": "webmention",
    "content":{"html":"<p>test</p>","text":"test"},
    "in-reply-to": <the target link be mentioned>,
    "wm-property": "in-reply-to",
    "wm-private": false
  }
  """
  schema "mentions" do
    belongs_to(:author, Author)

    field(:url, :string)
    field(:wm_received, :utc_datetime)
    field(:wm_id, :integer)
    # mention which page
    field(:wm_target, :string)

    field(:content, :string)
    field(:content_html, :string)
    # what kind of mention
    field(:wm_property, Ecto.Enum, values: [:like, :repost, :reply])
    field(:wm_private, :boolean)
  end

  def changeset(%Mention{} = mention, changes) do
    mention
    |> cast(changes, [
      :author_id,
      :url,
      :wm_received,
      :wm_id,
      :wm_target,
      :content,
      :content_html,
      :wm_property,
      :wm_private
    ])
    |> validate_required([
      :author_id,
      :url,
      :wm_received,
      :wm_id,
      :wm_target,
      :wm_property,
      :wm_private
    ])
    |> unique_constraint(:wm_id)
  end

  def create_mention(item) do
    Author.create_author(item["author"])

    url = item["author"]["url"]

    # find author from table
    author_id =
      WebmentionsDb.Repo.one(
        from(u in "authors",
          where: u.url == ^url,
          select: u.id
        )
      )

    # ensure this is not inserted webmention
    wm_id = item["wm-id"]

    case WebmentionsDb.Repo.one(
           from(u in "mentions",
             where: u.wm_id == ^wm_id,
             select: u.wm_id
           )
         ) do
      nil ->
        nil

      _ ->
        %Mention{}
        |> Mention.changeset(%{
          from_map(item)
          | author_id: author_id
        })
        |> WebmentionsDb.Repo.insert()

        %{id: mention_id, target: target_url} =
          WebmentionsDb.Repo.one(
            from(m in "mentions",
              where: m.wm_id == ^wm_id,
              select: %{id: m.id, target: m.wm_target}
            )
          )

        Target.create_target(target_url, mention_id)
    end
  end

  defp from_map(item) do
    {:ok, wm_received, _} = DateTime.from_iso8601(item["wm-received"])

    %{
      author_id: nil,
      url: item["url"],
      wm_received: wm_received,
      wm_id: item["wm-id"],
      wm_target: item["wm-target"],
      content_html: item["content"]["html"],
      content: item["content"]["text"],
      wm_property:
        case item["wm-property"] do
          "like-of" -> :like
          "repost-of" -> :repost
          "in-reply-to" -> :reply
        end,
      wm_private: item["wm-private"]
    }
  end

  def get_author_photo(mention) do
    query =
      from(m in Mention,
        join: a in Author,
        on: a.id == m.author_id,
        where: m.id == ^mention.id,
        select: a.photo
      )

    WebmentionsDb.Repo.all(query)
  end
end
