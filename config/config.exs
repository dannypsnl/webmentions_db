import Config

config :webmentions_db, ecto_repos: [WebmentionsDb.Repo]

config :webmentions_db, WebmentionsDb.Repo,
  database: "webmentions_db",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

config :webmentions_db, WebmentionsDb.Scheduler,
  jobs: [
    {"@daily",
     fn ->
       WebmentionsDb.Update.run()
       WebmentionsDb.Gen.run()
     end}
  ]

config :webmentions_db,
  domain: System.get_env("DOMAIN"),
  token: System.get_env("TOKEN"),
  output_dir: "trees",
  prefix: "mention-",
  extension: "tree"