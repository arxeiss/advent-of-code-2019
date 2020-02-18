defmodule Day10 do
  @doc """
    Convert string input into pixel map

    Examples:
      iex> Day10.parseIntoMap(".#..#
      ...>.....
      ...>#####
      ...>....#
      ...>...##
      ...>")
      %{{0, 2} => true, {1, 2} => true, {1, 4} => true, {2, 2} => true, {3, 0} => true, {3, 2} => true, {4, 0} => true, {4, 1} => true, {4, 2} => true, {4, 4} => true}
  """
  def parseIntoMap(input) do
    {map, _} =
      String.split(input, "\n", trim: true)
      |> Enum.reverse()
      |> Enum.reduce({%{}, 0}, fn line, {map, row} ->
        map =
          String.split(line, "", trim: true)
          |> Stream.with_index()
          |> Stream.filter(fn {code, _} -> code == "#" end)
          |> Enum.reduce(map, fn {_, column}, map ->
            Map.put(map, {column, row}, true)
          end)

        {map, row + 1}
      end)

    map
  end

  @doc """
    Count visible points from given position in asteroid map

    Examples:
    iex>Day10.is_asteroid_visible(
    ...>  %{{0, 1} => true, {0, 4} => true, {2, 0} => true, {2, 1} => true, {2, 2} => true, {2, 3} => true, {2, 4} => true, {3, 4} => true, {4, 3} => true, {4, 4} => true},
    ...>  {3, 4},
    ...>  {2, 2})
    true

    iex>Day10.is_asteroid_visible(
    ...>  %{{0, 1} => true, {0, 4} => true, {2, 0} => true, {2, 1} => true, {2, 2} => true, {2, 3} => true, {2, 4} => true, {3, 4} => true, {4, 3} => true, {4, 4} => true},
    ...>  {0, 4},
    ...>  {0, 1})
    true

    iex>Day10.is_asteroid_visible(
    ...>  %{{0, 1} => true, {0, 4} => true, {2, 0} => true, {2, 1} => true, {2, 2} => true, {2, 3} => true, {2, 4} => true, {3, 4} => true, {4, 3} => true, {4, 4} => true},
    ...>  {0, 1},
    ...>  {2, 1})
    true

    iex>Day10.is_asteroid_visible(
    ...>  %{{0, 1} => true, {0, 4} => true, {2, 0} => true, {2, 1} => true, {2, 2} => true, {2, 3} => true, {2, 4} => true, {3, 4} => true, {4, 3} => true, {4, 4} => true},
    ...>  {3, 4},
    ...>  {0, 1})
    false
  """
  def is_asteroid_visible(_asteroid_map, origin, destination) when origin == destination do
    false
  end

  def is_asteroid_visible(asteroid_map, origin, destination) do
    asteroids_between =
      Enum.count(asteroid_map, fn {asteroid_to_check, _} ->
        cond do
          asteroid_to_check == origin -> false
          asteroid_to_check == destination -> false
          true -> is_asteroid_between(asteroid_to_check, origin, destination)
        end
      end)

    asteroids_between == 0
  end

  @doc """
    Check if asteroid lies directly on line between origin and destination

    Examples:
      iex> Day10.is_asteroid_between({1,1}, {0,0}, {2,2})
      true

      iex> Day10.is_asteroid_between({1,1}, {0,1}, {2,1})
      true

      iex> Day10.is_asteroid_between({1,1}, {1,0}, {1,2})
      true
  """
  def is_asteroid_between(asteroid_to_check, origin, destination) do
    {x1, y1} = origin
    {x2, y2} = destination
    {x, y} = asteroid_to_check

    cond do
      x1 == x2 ->
        x == x1 && y >= min(y1, y2) && y <= max(y1, y2)

      y1 == y2 ->
        x >= min(x1, x2) && x <= max(x1, x2) && y == y1

      true ->
        m = (y1 - y2) / (x1 - x2)
        b = y1 - m * x1

        # Handle Floating-Point Arithmetic and rounding issue
        if abs(m * x + b - y) < 0.00001 do
          x >= min(x1, x2) && x <= max(x1, x2) && y >= min(y1, y2) && y <= max(y1, y2)
        else
          false
        end
    end
  end

  @doc """
    Find the best location for the monitoring station

    Examples:
      iex> Day10.get_best_location_for_station(".#..#
      ...>.....
      ...>#####
      ...>....#
      ...>...##
      ...>")
      %{loc: {3, 0}, visible: 8}
  """
  def get_best_location_for_station(input) do
    asteroid_map = parseIntoMap(input)

    Enum.reduce(asteroid_map, [], fn {origin, _}, acc ->
      cnt =
        Enum.count(asteroid_map, fn {destination, _} ->
          is_asteroid_visible(asteroid_map, origin, destination)
        end)

      [%{loc: origin, visible: cnt} | acc]
    end)
    |> Enum.max_by(fn %{:visible => cnt} -> cnt end)
  end

  defp get_normalized_vector_and_length(station_location, point2) do
    {x1, y1} = point2
    {x2, y2} = station_location
    u = x1 - x2
    v = y1 - y2
    length = :math.sqrt(u * u + v * v)
    u = u / length
    v = v / length

    {u, v, length}
  end

  defp asteroid_to_remove_in_next_step(asteroid_map, station_location, current_angle) do
    candidates_to_remove =
      Enum.reduce(asteroid_map, [], fn {asteroid, _}, acc ->
        if asteroid == station_location do
          acc
        else
          # counting always to vector [0, 1] - horizontal with up direction
          {u, v, length} = get_normalized_vector_and_length(station_location, asteroid)

          angle = :math.acos(v)
          # Handle Floating-Point Arithmetic and rounding issue
          angle = if(u < 0, do: 2 * :math.pi() - angle, else: angle) |> Float.floor(8)

          # Discard points with lower current angle
          if angle <= current_angle do
            acc
          else
            [{angle, length, asteroid} | acc]
          end
        end
      end)

    if length(candidates_to_remove) == 0 do
      # To prevent infinite loop, when found nothing
      if current_angle === -1 do
        {nil, nil, nil}
      else
        asteroid_to_remove_in_next_step(asteroid_map, station_location, -1)
      end
    else
      Enum.min_by(candidates_to_remove, fn {angle, length, _} -> trunc(angle * 100_000_000) * 1000 + length end)
    end
  end

  @doc """
    Find list of vaporized asteroids until maximum amount

    Examples:
      iex> Day10.get_list_of_vaporized_asteroids(
      ...>"##........
      ...>.###.....#
      ...>..#..#....
      ...>.#........
      ...>", {1, 0}, 8)
      [{9, 2}, {3, 2}, {1, 3}, {0, 3}, {5, 1}, {2, 1}, {2, 2}, {1, 2}]
  """
  def get_list_of_vaporized_asteroids(input, station_location, until_nth \\ 200) do
    asteroid_map = parseIntoMap(input)

    {_, removed_asteroids, _} =
      Enum.reduce_while(1..until_nth, {asteroid_map, [], -1}, fn _, {asteroid_map, removed_asteroids, current_angle} ->
        {current_angle, _, removed_asteroid} =
          asteroid_to_remove_in_next_step(asteroid_map, station_location, current_angle)

        if removed_asteroid == nil do
          {:halt, {asteroid_map, removed_asteroids, nil}}
        else
          {:cont, {Map.delete(asteroid_map, removed_asteroid), [removed_asteroid | removed_asteroids], current_angle}}
        end
      end)

    removed_asteroids
  end

  @doc """
    Run Day 10
  """
  def run do
    input = File.read!('input.txt')
    %{loc: station_location, visible: visible_asteroids} = get_best_location_for_station(input)
    lines = length(String.split(input, "\n", trim: true))

    raw_result = get_list_of_vaporized_asteroids(input, station_location)

    [{last_vaporized_x, last_vaporized_y} | _] = raw_result

    %{
      part1: visible_asteroids,
      part1_station: station_location,
      part2_original: {last_vaporized_x, last_vaporized_y},
      part2: last_vaporized_x * 100 + (lines - last_vaporized_y - 1)
    }
  end
end
