defmodule WebmentionsDb.MixProject do
  use Mix.Project

  def project do
    [
      app: :webmentions_db,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: [:logger], mod: {WebmentionsDb, []}]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "3.11.2"},
      {:ecto_sql, "~> 3.11.2"},
      {:postgrex, ">= 0.0.0"},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.4.4"},
      {:quantum, "~> 3.0"}
    ]
  end
end
