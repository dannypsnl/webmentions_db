defmodule WebmentionsDbTest do
  use ExUnit.Case
  doctest WebmentionsDb

  test "test generated mention-author string" do
    assert Generate.mention_author("https://instance/@who", "https://where.png") ==
             "\\mention-author{https://instance/@who}{https://where.png}"
  end
end
