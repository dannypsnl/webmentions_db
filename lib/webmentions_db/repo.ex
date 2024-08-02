defmodule WebmentionsDb.Repo do
  use Ecto.Repo,
    otp_app: :webmentions_db,
    adapter: Ecto.Adapters.Postgres
end
