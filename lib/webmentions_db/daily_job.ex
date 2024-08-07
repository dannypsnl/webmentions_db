defmodule WebmentionsDb.DailyJob do
  use GenServer

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_cast(:run, _, state) do
    WebmentionsDb.Update.run()
    WebmentionsDb.Gen.run()
    {:noreply, state}
  end
end
