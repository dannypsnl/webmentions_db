defmodule WebmentionsDb.GenerateJson do
  def like(url, profile_photo) do
    Jason.encode!(%{
      kind: :like,
      url: url,
      profile_photo: profile_photo
    })
  end

  def repost(url, profile_photo) do
    Jason.encode!(%{
      kind: :repost,
      url: url,
      profile_photo: profile_photo
    })
  end

  def reply(url, profile_photo, content) do
    Jason.encode!(%{
      kind: :reply,
      url: url,
      profile_photo: profile_photo,
      content: content
    })
  end
end
