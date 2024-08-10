defmodule WebmentionsDb.Generate do
  alias WebmentionsDb.Repo
  alias Ecto.Multi

  @doc """
  The function iterate all targets and generate output files for them
  """
  def run(force? \\ false) do
    Target.list_all()
    |> Enum.map(&Task.async(fn -> task(&1, force?) end))
    |> Enum.map(&Task.await/1)
    |> Enum.reduce(Multi.new(), fn changeset, multi ->
      case changeset do
        nil ->
          multi

        _ ->
          multi
          |> Multi.update(:targets, changeset)
      end
    end)
    |> Repo.transaction()
  end

  defp task(target, force?) do
    %{mentions: mentions, latest_mention: latest_mention} = target

    [m | _] = mentions
    new_latest_mention = m.wm_received

    new_latest_mention =
      cond do
        latest_mention == nil ->
          new_latest_mention

        DateTime.compare(latest_mention, new_latest_mention) == :lt ->
          new_latest_mention

        force? ->
          latest_mention

        true ->
          nil
      end

    if new_latest_mention != nil do
      try do
        generate(target)
        Target.changeset(target, %{latest_mention: new_latest_mention})
      rescue
        reason ->
          %{url: url} = target
          IO.puts("failed to generate file for target #{url}")
          IO.inspect(reason)
          nil
      end
    else
      nil
    end
  end

  def mention_author(url, profile_photo) do
    "\\mention-author{#{url}}{#{profile_photo}}"
  end

  defp generate(%{output_file: output, mentions: mentions}) do
    {repost_list, like_list, reply_list} = WebmentionsDb.GenerateMap.generate_lists(mentions)

    output_dir = Application.fetch_env!(:webmentions_db, :output_dir)
    File.mkdir_p!(output_dir)
    file = File.open!("#{output_dir}/#{output}", [:write, :utf8])

    IO.write(file, "\\xmlns:html{http://www.w3.org/1999/xhtml}\n")
    IO.write(file, "\\taxon{reaction}\n")
    IO.write(file, "\\import{webmention-macros}\n\n")

    IO.write(file, "\\boost\n")

    repost_list
    |> IO.inspect()
    |> Enum.map(fn %{url: url, profile_photo: profile_photo} ->
      IO.write(
        file,
        "  #{mention_author(url, profile_photo)}\n"
      )
    end)

    IO.write(file, "\\like\n")

    like_list
    |> IO.inspect()
    |> Enum.map(fn %{url: url, profile_photo: profile_photo} ->
      IO.write(
        file,
        "  #{mention_author(url, profile_photo)}\n"
      )
    end)

    IO.write(file, "\\ul{\n")

    reply_list
    |> IO.inspect()
    |> Enum.map(fn %{url: url, profile_photo: profile_photo, content: content} ->
      IO.write(
        file,
        "  \\li{#{mention_author(url, profile_photo)} #{content}}\n"
      )
    end)

    IO.write(file, "}\n")

    File.close(file)
  end
end
