# This script through all existed mentions, and create target if there are some missing
#
# Since every new mention will also try to create target, so this should not be required for new repository
import Ecto.Query

WebmentionsDb.start([], [])

query =
  from(m in "mentions",
    select: %{id: m.id, target: m.wm_target}
  )

mentions = query |> WebmentionsDb.Repo.all()

mentions
|> Enum.map(fn %{target: url, id: mention_id} ->
  Target.create_target(url, mention_id)
end)
