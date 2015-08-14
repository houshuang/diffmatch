defmodule Array do
  import MultiDef

  def diff(x, y), do: _diff(x, y, 0, [])

  mdef _diff do
    [h|t], [h1|t1], i, acc when h == h1 -> _diff t, t1, i + 1, acc
    [h|t], [h1|t1], i, acc ->
      _diff [t], [h1|t1], i, [ %{d: i} | acc ]
    old, [], i, acc ->
      Enum.map(i..i + length(old)-1, fn x -> %{d: x} end)
      |> List.flatten(acc)
    [], _, i, acc -> acc
  end

end
