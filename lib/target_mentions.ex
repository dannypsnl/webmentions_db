defmodule TargetMentions do
  use Ecto.Schema

  schema "target_mentions" do
    belongs_to(:target, Target)
    belongs_to(:mention, Mention)
  end
end
