defmodule WebmentionsDb do
  use Application

  def start(_type, _args) do
    HTTPoison.start()

    children = [
      WebmentionsDb.Repo,
      WebmentionsDb.Scheduler
    ]

    opts = [strategy: :one_for_one, name: WebmentionsDb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def domain() do
    Application.fetch_env!(:webmentions_db, :domain)
  end

  def token() do
    Application.fetch_env!(:webmentions_db, :token)
  end
end
