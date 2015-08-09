defmodule Ops do
  use StateSync

  @path [:chat, :presence]
  defop "user:online" do
    emit "has_been_online", args
    emit "new:msg", %{newmsg: "#{args.usernick} just entered the room"}
    Set.put(state, args.usernick)
  end

  @path [:chat, :has_been]
  defop "has_been_online", do: [ args.usernick | state ]

  @path [:chat, :msglist]
  defop "new:msg", do: [args.newmsg | state]
end
