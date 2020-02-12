defmodule Day6 do
  @doc """
    Parse orbit maps
  """
  def parse_orbit_map(map, root) do
    String.split(map, "\n", trim: true)
    |> Enum.reduce(%{}, fn orbit_relation, acc ->
      [barycenter, orbit] = String.split(orbit_relation, ")", trim: true, parts: 2)

      Map.update(acc, barycenter, %{children: [orbit]}, fn %{children: orbits} ->
        %{children: [orbit | orbits]}
      end)
    end)
    |> set_orbit_parents_and_leafs(root)
  end

  defp set_orbit_parents_and_leafs(map, node, parent \\ nil) do
    if Map.has_key?(map, node) == false do
      Map.put(map, node, %{children: [], parent: parent})
    else
      map = Map.update!(map, node, fn node_value -> %{parent: parent, children: node_value.children} end)
      Enum.reduce(Map.get(map, node).children, map, fn child, map -> set_orbit_parents_and_leafs(map, child, node) end)
    end
  end

  @doc """
    Count direct and indirect orbits
  """
  def count_child_orbits(map, barycenter, nested_level \\ 1) do
    Enum.reduce(Map.get(map, barycenter, %{children: []}).children, 0, fn orbit, acc ->
      acc + nested_level + count_child_orbits(map, orbit, nested_level + 1)
    end)
  end

  defp get_node_list_to_root(map, orbit) do
    orbit_value = Map.get(map, orbit)

    if orbit_value.parent == nil do
      [orbit]
    else
      [orbit | get_node_list_to_root(map, orbit_value.parent)]
    end
  end

  @doc """
    Get steps between two orbits
    Do not forget substract 2 as we need to know how to get to same parent
  """
  def count_distance_between_orbits(map, orbit1, orbit2) do
    orbit1_root_list = get_node_list_to_root(map, orbit1)
    orbit2_root_list = get_node_list_to_root(map, orbit2)

    length(orbit1_root_list -- orbit2_root_list) + length(orbit2_root_list -- orbit1_root_list) - 2
  end

  @doc """
    Running part 1 and part 2
  """
  def run do
    orbit_map =
      File.read!('input.txt')
      |> parse_orbit_map("COM")

    %{
      part1: count_child_orbits(orbit_map, "COM"),
      part2: count_distance_between_orbits(orbit_map, "YOU", "SAN")
    }
  end
end
