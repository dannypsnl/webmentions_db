# This script initial the whole DB
#
# it will pull ALL data via the http GET call below,
# so this is not a good script when ALL data is large,
# but this might be required on a new computer
#
# After this initial, we will get all mentions on the web into local DB,
# further job is based on this.
import Ecto.Query

WebmentionsDb.start([], [])

domain = Application.fetch_env!(:webmentions_db, :domain)
token = Application.fetch_env!(:webmentions_db, :token)

{:ok, resp} =
  HTTPoison.get(
    "https://webmention.io/api/mentions.jf2?domain=#{WebmentionsDb.domain()}&token=#{WebmentionsDb.token()}"
  )

{:ok, json} = resp.body |> Jason.decode()

json["children"]
|> Enum.map(fn item ->
  Mention.create_mention(item)
end)

query =
  from(m in "mentions",
    select: m.url
  )

WebmentionsDb.Repo.all(query)
|> IO.inspect()
