defmodule WebmentionsDb.GenerateMap do
  def generate_lists(mentions) do
    repost_list =
      mentions
      |> Enum.filter(fn m -> m.wm_property == :repost end)
      |> Enum.map(&repost(&1.url, Mention.get_author_photo(&1)))

    like_list =
      mentions
      |> Enum.filter(fn m -> m.wm_property == :like end)
      |> Enum.map(&like(&1.url, Mention.get_author_photo(&1)))

    reply_list =
      mentions
      |> Enum.filter(fn m -> m.wm_property == :reply end)
      |> Enum.map(&reply(&1.url, Mention.get_author_photo(&1), &1.content))

    {repost_list, like_list, reply_list}
  end

  defp repost(url, profile_photo) do
    %{
      kind: :repost,
      url: url,
      profile_photo: profile_photo
    }
  end

  defp like(url, profile_photo) do
    %{
      kind: :like,
      url: url,
      profile_photo: profile_photo
    }
  end

  defp reply(url, profile_photo, content) do
    %{
      kind: :reply,
      url: url,
      profile_photo: profile_photo,
      content: content
    }
  end
end
