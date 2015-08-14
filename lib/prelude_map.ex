defmodule Prelude.Map do
  # provide a list of maps, and a list of keys to group by. All maps must
  # have all the gorup_by fields, other fields can vary.
  # for example
  #
  # group_by([%{name: "stian", group: 1, cat: 2},
  #  %{name: "per", group: 1, cat: 1}], [:group, :cat])
  #
  # => %{1 => %{1 => %{cat: 1, group: 1, name: "per"},
  #      2 => %{cat: 2, group: 1, name: "stian"}}}
  def group_by(lst, groups) do
    Enum.reduce(lst, %{}, fn item, map ->
      path = Enum.map(groups, fn group -> Map.get(item, group) end)
      deep_put(map, path, item)
    end)
  end

  # put an arbitrarily deep key into an existing map. If a value
  # already exists at that level, it is turned into a list
  # for example:

  # deep_put(%{}, [:a, :b, :c], "1")
  # => %{a: %{b: %{c: "1"}}}

  # deep_put(%{a: %{b: %{c: "1"}}}, [:a, :b, :c, :d], "2")
  # => %{a: %{b: %{c: [{:d, "2"}, "1"]}}}
  def deep_put(map, path, val, override \\ false) do
    state = {map, []}
    Enum.reduce(path, state, fn x, {acc, cursor} ->
      cursor = [ x | cursor ]
      final = length(cursor) == length(path)
      newval = case get_in(acc, Enum.reverse(cursor)) do
        h when is_list(h) -> [ val | h ]
        nil -> if final, do: val, else: %{}
        h = %{} -> if final, do: [val, h], else: h
        h -> if final, do: [ val, h ], else: [h]
      end
      { put_in(acc, Enum.reverse(cursor), newval), cursor }
    end)
    |> fn x -> elem(x, 0) end.()
  end

  # remove a map key arbitrarily deep in a structure, similar to put_in
  # for example
  #
  # a = {a: %{b: %{c: %{d: 1, e: 1}}}}
  # del_in(a, [:a;, :b, :c] :d) -> %{a: %{b: %{c: %{e: 1}}}}
  def del_in(object, path, item) do
    obj = get_in(object, path)
    put_in(object, path, Map.delete(obj, item))
  end

  # shallow atomify of map keys (no error if keys are already atoms)
  def atomify(map) do
    Enum.map(map, fn {k,v} -> {Prelude.safe_to_atom(k), v} end)
    |> Enum.into(%{})
  end

  # shallow stringify of atom map keys (no error if keys are already strings)
  def stringify(map) do
    Enum.map(map, fn {k,v} -> {Prelude.safe_to_string(k), v} end)
    |> Enum.into(%{})
  end

  # assumes that a map key points to an array, and appends item to array.
  # if map key does not exist, it will be created.
  def append(map, key, val) do
    Map.update(map, key, [val], fn x -> List.insert_at(x, 0, val) end)
  end
end

