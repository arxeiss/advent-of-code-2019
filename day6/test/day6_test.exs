defmodule Day6Test do
  use ExUnit.Case
  doctest Day6

  test "Parse orbit map and count direct and indirect orbits" do
    assert Day6.parse_orbit_map("COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L\n", "COM")
           |> Day6.count_child_orbits("COM") === 42
  end

  test "Parse orbit map and count distance between two orbits" do
    assert Day6.parse_orbit_map("COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L\nK)YOU\nI)SAN\n", "COM")
           |> Day6.count_distance_between_orbits("YOU", "SAN") === 4
  end
end
