defmodule WebmentionsDb.Update do
  import Ecto.Query

  @doc """
  This function pull NEW data from webmention.io into local DB

  At the end it provides all mentioned targets in updates
  """
  def run() do
    query =
      from(m in Mention,
        order_by: [desc: m.wm_received],
        select: m.wm_received
      )

    latest_receive =
      query
      |> first()
      |> WebmentionsDb.Repo.one()

    %{year: year, month: month, day: day, hour: hour, minute: minute, second: second} =
      latest_receive

    since =
      %DateTime{
        year: year,
        month: month,
        day: day,
        zone_abbr: "UTC",
        hour: hour,
        minute: minute,
        second: second,
        microsecond: {0, 0},
        utc_offset: 0,
        std_offset: 0,
        time_zone: "Etc/UTC"
      }
      |> DateTime.to_iso8601()

    {:ok, resp} =
      HTTPoison.get(
        "https://webmention.io/api/mentions.jf2?domain=#{WebmentionsDb.domain()}&token=#{WebmentionsDb.token()}&since=#{since}"
      )

    {:ok, json} = resp.body |> Jason.decode()

    json["children"]
    |> Enum.map(fn item ->
      Mention.create_mention(item)
      item["wm-target"]
    end)
    |> Enum.uniq()
  end
end
