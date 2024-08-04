defmodule WebmentionsDb.Gen do
  alias WebmentionsDb.Repo
  alias Ecto.Multi

  @doc """
  The function iterate all targets and generate output files for them
  """
  def run() do
    Target.list_all()
    |> Enum.reduce(Multi.new(), fn target, multi ->
      %{mentions: mentions, latest_mention: latest_mention} = target

      [m | _] = mentions
      new_latest_mention = m.wm_received

      run_generate? =
        case latest_mention do
          nil ->
            true

          _ ->
            DateTime.compare(latest_mention, new_latest_mention) == :lt
        end

      if run_generate? do
        generate(target)

        multi
        |> Multi.update(:targets, Target.changeset(target, %{latest_mention: new_latest_mention}))
      else
        multi
      end
    end)
    |> Repo.transaction()
  end

  def mention_author(url, profile_photo) do
    "\\mention-author{#{url}}{#{profile_photo}}"
  end

  defp generate(%{output_file: output, mentions: mentions}) do
    output_dir = Application.fetch_env!(:webmentions_db, :output_dir)
    file = File.open!("#{output_dir}/#{output}", [:write, :utf8])

    IO.write(file, "\\xmlns:html{http://www.w3.org/1999/xhtml}\n")
    IO.write(file, "\\taxon{reaction}\n")
    IO.write(file, "\\import{webmention-macros}\n\n")
    IO.write(file, "\\boost\n")

    mentions
    |> Enum.filter(fn m -> m.wm_property == :repost end)
    |> IO.inspect()
    |> Enum.map(fn m ->
      url = m.url
      profile_photo = Mention.get_author_photo(m)

      IO.write(
        file,
        "  #{mention_author(url, profile_photo)}\n"
      )
    end)

    IO.write(file, "\\like\n")

    mentions
    |> Enum.filter(fn m -> m.wm_property == :like end)
    |> IO.inspect()
    |> Enum.map(fn m ->
      url = m.url
      profile_photo = Mention.get_author_photo(m)

      IO.write(
        file,
        "  #{mention_author(url, profile_photo)}\n"
      )
    end)

    IO.write(file, "\\ul{\n")

    mentions
    |> Enum.filter(fn m -> m.wm_property == :reply end)
    |> IO.inspect()
    |> Enum.map(fn m ->
      url = m.url
      profile_photo = Mention.get_author_photo(m)
      content = m.content

      IO.write(
        file,
        "  \\li{#{mention_author(url, profile_photo)} #{content}}\n"
      )
    end)

    IO.write(file, "}\n")

    File.close(file)
  end
end
