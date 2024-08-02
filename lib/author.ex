defmodule Author do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @doc """
  Raw format of author

  {
    "type": "card",
    "name": <author's show name>
    "photo": <url to avatar>
    "url": <url to author>
  }
  """
  schema "authors" do
    field(:url, :string)
    field(:name, :string)
    field(:photo, :string)

    has_many(:mentions, Mention)
  end

  def changeset(%Author{} = author, changes) do
    author
    |> cast(changes, [:url, :name, :photo])
    |> validate_required([:url, :photo])
    |> unique_constraint(:url)
  end

  def create_author(item) do
    changes = from_map(item)

    query =
      from(u in "authors",
        where: u.url == ^changes.url,
        select: u.url
      )

    # we have to ensure the author is new one, or we do nothing
    case WebmentionsDb.Repo.one(query) do
      nil ->
        %Author{}
        |> Author.changeset(changes)
        |> WebmentionsDb.Repo.insert()

      _ -> nil
    end
  end

  defp from_map(item) do
    %{
      url: item["url"],
      name: item["name"],
      photo: item["photo"]
    }
  end
end
